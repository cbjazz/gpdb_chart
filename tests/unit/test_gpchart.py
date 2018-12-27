import unittest

from gpchart import sum

class TestSum(unittest.TestCase):

    def test_init(self):
        data = [1,2,3]
        result = sum(data)
        self.assertEqual(result, 6)

if __name__ == '__main__':
    unittest.main()
