import json
from datetime import datetime


class api_validator:
    """
    Business validation library for Robot Framework.
    """

    def _load_json(self, response):
        if hasattr(response, "json"):
            return response.json()
        if isinstance(response, str):
            return json.loads(response)
        return response

    def _assert_non_negative_numeric_string(self, value, field_name):
        try:
            numeric = float(value)
        except (ValueError, TypeError):
            raise AssertionError(f"'{field_name}' must be a numeric string, got: {value!r}")
        assert numeric >= 0, f"'{field_name}' must be >= 0, got: {numeric}"
        return numeric

    def _validate_ticker_object(self, ticker, pair_id):
        price_fields = ["buy", "high", "last", "low", "sell"]
        for field in price_fields + ["server_time"]:
            assert field in ticker, f"Ticker '{pair_id}' missing required field: '{field}'"

        for field in price_fields:
            self._assert_non_negative_numeric_string(ticker[field], f"{pair_id}.{field}")

        assert int(ticker["server_time"]) > 0, f"Ticker '{pair_id}': 'server_time' must be > 0"

        low = float(ticker["low"])
        last = float(ticker["last"])
        high = float(ticker["high"])

        assert low <= high, f"Ticker '{pair_id}': 'low' ({low}) > 'high' ({high})"
        assert low <= last <= high, f"Ticker '{pair_id}': 'last' ({last}) not within range [{low}, {high}]"

    def validate_server_time(self, response):
        data = self._load_json(response)
        assert "timezone" in data, "Missing required field: 'timezone'"
        assert "server_time" in data, "Missing required field: 'server_time'"
        assert data["timezone"] == "UTC", f"Expected timezone 'UTC', got: {data['timezone']!r}"
        
        server_time = int(data["server_time"])
        assert server_time > 0, f"'server_time' must be > 0, got: {server_time}"

    def validate_price_increments(self, response):
        data = self._load_json(response)
        assert "increments" in data, "Missing required field: 'increments'"
        increments = data["increments"]
        assert len(increments) > 0, "No trading pairs found in 'increments'"
        assert "btc_idr" in increments, "Expected 'btc_idr' in increments"
        for pair, increment in increments.items():
            try:
                value = float(increment)
            except (ValueError, TypeError):
                raise AssertionError(f"Increment for '{pair}' is not numeric: {increment!r}")
            assert value > 0, f"Increment for '{pair}' must be > 0, got: {value}"

    def validate_pairs(self, response):
        data = self._load_json(response)
        assert isinstance(data, list), f"Expected list of trading pairs, got: {type(data).__name__}"
        assert len(data) > 0, "Trading pairs list is empty"
        ticker_ids = [p.get("ticker_id") for p in data]
        assert "btc_idr" in ticker_ids, "Expected 'btc_idr' in trading pairs"
        
        required_fields = [
            "id", "symbol", "base_currency", "traded_currency",
            "traded_currency_unit", "description", "ticker_id",
            "volume_precision", "price_precision", "price_round",
            "pricescale", "trade_min_base_currency",
            "trade_min_traded_currency", "url_logo", "url_logo_png",
        ]
        for pair in data:
            pair_id = pair.get("id", "<unknown>")
            for field in required_fields:
                assert field in pair, f"Pair '{pair_id}' missing required field: '{field}'"
            if "has_memo" in pair:
                assert isinstance(pair["has_memo"], bool), f"Pair '{pair_id}': 'has_memo' must be boolean"
            assert isinstance(pair["volume_precision"], (int, float)) and pair["volume_precision"] >= 0, "volume_precision invalid"
            assert isinstance(pair["price_precision"], (int, float)) and pair["price_precision"] >= 0, "price_precision invalid"
            assert pair["trade_min_base_currency"] >= 0, "trade_min_base_currency must be >= 0"
            assert pair["trade_min_traded_currency"] >= 0, "trade_min_traded_currency must be >= 0"

    def validate_summaries(self, response):
        data = self._load_json(response)
        for key in ["tickers", "prices_24h", "prices_7d"]:
            assert key in data, f"Missing required top-level key: '{key}'"
        tickers = data["tickers"]
        assert len(tickers) > 0, "Summaries 'tickers' is empty"
        assert "btc_idr" in tickers, "Expected 'btc_idr' in summaries tickers"
        for pair_id, ticker in tickers.items():
            self._validate_ticker_object(ticker, pair_id)
        prices_24h = data["prices_24h"]
        assert isinstance(prices_24h, dict) and len(prices_24h) > 0, "'prices_24h' must be non-empty dict"
        prices_7d = data["prices_7d"]
        assert isinstance(prices_7d, dict) and len(prices_7d) > 0, "'prices_7d' must be non-empty dict"

    def validate_ticker(self, response):
        data = self._load_json(response)
        assert "ticker" in data, "Missing required top-level key: 'ticker'"
        self._validate_ticker_object(data["ticker"], "ticker")

    def validate_ticker_all(self, response):
        data = self._load_json(response)
        assert "tickers" in data, "Missing required top-level key: 'tickers'"
        tickers = data["tickers"]
        assert len(tickers) > 0, "'tickers' is empty"
        assert "btc_idr" in tickers, "Expected 'btc_idr' in tickers"
        for pair_id, ticker in tickers.items():
            self._validate_ticker_object(ticker, pair_id)

    def validate_depth(self, response):
        data = self._load_json(response)
        assert "buy" in data, "Missing required field: 'buy'"
        assert "sell" in data, "Missing required field: 'sell'"
        assert isinstance(data["buy"], list), "'buy' must be an array"
        assert isinstance(data["sell"], list), "'sell' must be an array"
        assert len(data["buy"]) > 0 or len(data["sell"]) > 0, "Order book is completely empty"
        for side, orders in [("buy", data["buy"]), ("sell", data["sell"])]:
            for i, order in enumerate(orders):
                assert isinstance(order, list) and len(order) == 2, f"'{side}[{i}]' must be a [price, amount] array"
                price, amount = order
                self._assert_non_negative_numeric_string(price, f"{side}[{i}].price")
                self._assert_non_negative_numeric_string(amount, f"{side}[{i}].amount")

    def validate_trades(self, response):
        data = self._load_json(response)
        assert isinstance(data, list), f"Expected list of trades, got: {type(data).__name__}"
        assert len(data) > 0, "Trades list is empty"
        required_fields = ["date", "price", "amount", "tid", "type"]
        valid_types = {"buy", "sell"}
        for i, trade in enumerate(data):
            for field in required_fields:
                assert field in trade, f"Trade[{i}] missing required field: '{field}'"
            self._assert_non_negative_numeric_string(trade["price"], f"trade[{i}].price")
            self._assert_non_negative_numeric_string(trade["amount"], f"trade[{i}].amount")
            assert int(trade["date"]) > 0, f"trade[{i}].date must be > 0"
            assert trade["type"] in valid_types, f"trade[{i}].type must be 'buy' or 'sell', got: {trade['type']!r}"