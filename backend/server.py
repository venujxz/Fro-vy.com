#!/usr/bin/env python3
"""
Fro-vy PayHere Payment Backend Server
A simple Flask server for handling PayHere payments in Sri Lanka
"""

import hashlib
import json
import os
from datetime import datetime
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import parse_qs, urlparse

# Configuration - Load from environment or use defaults
PAYHERE_MERCHANT_ID = os.environ.get('PAYHERE_MERCHANT_ID', '4OVybuzvTQe4JH5Ex67puH3Tc')
PAYHERE_MERCHANT_SECRET = os.environ.get('PAYHERE_MERCHANT_SECRET', '4Pb1UIhvL9x4PVs5GrfKJp8MSO9yeeayS4kmeNRrDwna')
PORT = int(os.environ.get('PORT', 3000))

# In-memory storage for payments (use a database in production)
payments = {}

class PayHereHandler(BaseHTTPRequestHandler):
    def _set_headers(self, status=200, content_type='application/json'):
        self.send_response(status)
        self.send_header('Content-Type', content_type)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

    def _send_json(self, data, status=200):
        self._set_headers(status)
        self.wfile.write(json.dumps(data).encode())

    def do_OPTIONS(self):
        self._set_headers()

    def do_GET(self):
        parsed_path = urlparse(self.path)
        path = parsed_path.path

        if path == '/health':
            self._send_json({
                'status': 'ok',
                'timestamp': datetime.now().isoformat()
            })

        elif path.startswith('/payhere/verify/'):
            order_id = path.split('/')[-1]
            payment = payments.get(order_id)

            if payment:
                self._send_json({
                    'verified': payment.get('verified', False),
                    'orderId': payment.get('orderId'),
                    'paymentId': payment.get('paymentId'),
                    'planName': payment.get('planName'),
                    'timestamp': payment.get('timestamp')
                })
            else:
                self._send_json({'verified': False, 'error': 'Payment not found'})

        elif path == '/payhere/payments':
            self._send_json(list(payments.values()))

        else:
            self._send_json({'error': 'Not found'}, 404)

    def do_POST(self):
        content_length = int(self.headers.get('Content-Length', 0))
        post_data = self.rfile.read(content_length)
        parsed_path = urlparse(self.path)
        path = parsed_path.path

        if path == '/payhere/generate-hash':
            try:
                data = json.loads(post_data.decode())
                order_id = data.get('orderId')
                amount = data.get('amount')
                currency = data.get('currency')

                if not all([order_id, amount, currency]):
                    self._send_json({'error': 'Missing required fields'}, 400)
                    return

                # Generate hash according to PayHere specification
                # Hash = MD5(merchant_id + order_id + amount + currency + MD5(merchant_secret).upper())
                secret_hash = hashlib.md5(PAYHERE_MERCHANT_SECRET.encode()).hexdigest().upper()
                hash_string = f"{PAYHERE_MERCHANT_ID}{order_id}{amount}{currency}{secret_hash}"
                payment_hash = hashlib.md5(hash_string.encode()).hexdigest().upper()

                print(f"Generated hash for order: {order_id}")
                self._send_json({'hash': payment_hash})

            except json.JSONDecodeError:
                self._send_json({'error': 'Invalid JSON'}, 400)
            except Exception as e:
                print(f"Error generating hash: {e}")
                self._send_json({'error': str(e)}, 500)

        elif path == '/payhere/notify':
            try:
                # Parse URL-encoded form data
                data = parse_qs(post_data.decode())

                # Extract fields (parse_qs returns lists, so get first item)
                merchant_id = data.get('merchant_id', [''])[0]
                order_id = data.get('order_id', [''])[0]
                payment_id = data.get('payment_id', [''])[0]
                payhere_amount = data.get('payhere_amount', [''])[0]
                payhere_currency = data.get('payhere_currency', [''])[0]
                status_code = data.get('status_code', [''])[0]
                md5sig = data.get('md5sig', [''])[0]
                custom_1 = data.get('custom_1', [''])[0]

                print(f"PayHere notification received: order={order_id}, payment={payment_id}, status={status_code}")

                # Verify the MD5 signature
                secret_hash = hashlib.md5(PAYHERE_MERCHANT_SECRET.encode()).hexdigest().upper()
                local_sig = hashlib.md5(
                    f"{merchant_id}{order_id}{payhere_amount}{payhere_currency}{status_code}{secret_hash}".encode()
                ).hexdigest().upper()

                if local_sig != md5sig:
                    print(f"Invalid signature for order: {order_id}")
                    self._set_headers(400, 'text/plain')
                    self.wfile.write(b'Invalid signature')
                    return

                # Store payment status
                payments[order_id] = {
                    'orderId': order_id,
                    'paymentId': payment_id,
                    'amount': payhere_amount,
                    'currency': payhere_currency,
                    'statusCode': status_code,
                    'planName': custom_1,
                    'timestamp': datetime.now().isoformat(),
                    'verified': status_code == '2'  # 2 = success
                }

                if status_code == '2':
                    print(f"Payment successful for order: {order_id}")
                else:
                    print(f"Payment not successful. Status: {status_code}")

                self._set_headers(200, 'text/plain')
                self.wfile.write(b'OK')

            except Exception as e:
                print(f"Error processing notification: {e}")
                self._set_headers(500, 'text/plain')
                self.wfile.write(b'Error')

        else:
            self._send_json({'error': 'Not found'}, 404)

    def log_message(self, format, *args):
        print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] {args[0]}")


def run_server():
    server_address = ('', PORT)
    httpd = HTTPServer(server_address, PayHereHandler)
    print(f"=" * 50)
    print(f"Fro-vy PayHere Server")
    print(f"=" * 50)
    print(f"Server running on port {PORT}")
    print(f"Health check: http://localhost:{PORT}/health")
    print(f"Merchant ID: {PAYHERE_MERCHANT_ID}")
    print(f"=" * 50)
    print("Waiting for requests...")
    httpd.serve_forever()


if __name__ == '__main__':
    run_server()
