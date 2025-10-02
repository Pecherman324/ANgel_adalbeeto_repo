import unittest
import json
from app import app

class TestApp(unittest.TestCase):
    
    def setUp(self):
        self.app = app.test_client()
        self.app.testing = True
        
    def test_index_page(self):
        """Test that the index page loads correctly"""
        response = self.app.get('/')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'DevOps', response.data)
        self.assertIn(b'Angel Adalberto', response.data)
        
    def test_status_endpoint(self):
        """Test the status API endpoint"""
        response = self.app.get('/api/status')
        self.assertEqual(response.status_code, 200)
        
        data = json.loads(response.data)
        self.assertEqual(data['status'], 'OK')
        self.assertIn('timestamp', data)
        self.assertIn('environment', data)
        
    def test_health_endpoint(self):
        """Test the health API endpoint"""
        response = self.app.get('/api/health')
        self.assertEqual(response.status_code, 200)
        
        data = json.loads(response.data)
        self.assertEqual(data['health'], 'healthy')
        self.assertEqual(data['version'], '1.0.0')
        self.assertEqual(data['uptime'], 'running')
        
    def test_nonexistent_endpoint(self):
        """Test that nonexistent endpoints return 404"""
        response = self.app.get('/nonexistent')
        self.assertEqual(response.status_code, 404)

if __name__ == '__main__':
    unittest.main()
