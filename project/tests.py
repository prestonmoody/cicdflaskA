from __init__ import create_app
import unittest

class Test(unittest.TestCase):
  def setUp(self):
    self.app = create_app('test')
    self.client = self.app.test_client()

  def test_index(self):
    response = self.client.get("/")
    print (response.data)
    self.assertEqual(response.data, b"Index")

if __name__ == '__main__':
  unittest.main()
