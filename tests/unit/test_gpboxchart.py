import unittest

from gpchart.gpboxchart import GpdbBoxChart
import matplotlib as mpl
import os.path # for checking file
import os      # for removing test file
import base64  # for decoding from base64
import imghdr  # for checking image format

class TestBoxChart(unittest.TestCase):

    def test_save_fig(self):
        '''
        This tests if the plot is saved with file.
        We only check whether the file is exsist and
            do not check whether the plot was drawn rightly.
        '''
        options = '''{
            "style":"bmh",
            "figure.figsize": [12.0, 6.0],
            "legend.loc":"upper right",
            "axes.color_map":"PuOr",
            "axes.color_alpha":0.7
        }'''
        filename = "box_unit_test.png"
        chart = GpdbBoxChart('test', options, 1.5)
        chart.draw_chart([1,2,3], [1,2,3], ['A', 'A', 'A'], [1,1,1])
        chart.save_file(filename)
        assert os.path.isfile(filename), "Plot does not saved."
        try:
            os.remove(filename)
        except OSError as e:
            print ("Error: %s - %s." % (e.filename, e.strerror))

if __name__ == '__main__':
    unittest.main()
