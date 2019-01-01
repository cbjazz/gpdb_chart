import unittest

from gpchart.gpmultiplotchart import GpdbMultiPlotChart
import matplotlib as mpl
import os.path # for checking file
import os      # for removing test file
import base64  # for decoding from base64
import imghdr  # for checking image format

class TestMultiPlotChart(unittest.TestCase):
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
            "axes.color_map":"hsv",
            "axes.color_alpha":0.7,
            "figure.subplot.wspace":0.1,
            "figure.subplot.hspace":0.1
        }'''
        filename = "multi_plot_unit_test.png"
        chart = GpdbMultiPlotChart('test', options)
        chart.draw_chart([1, 2, 3, 4, 5, 1, 2, 3, 4],
                         [1, 2, 3, 4, 5, 6, 4, 2, 6],
                         ['A', 'A', 'A', 'A', 'A', 'B', 'B', 'B', 'B'],
                         [1, 1, 1, 1, 1, 2, 2, 2, 2])
        chart.save_file(filename)
        assert os.path.isfile(filename), "Plot does not saved."
        try:
            os.remove(filename)
        except OSError as e:
            print ("Error: %s - %s." % (e.filename, e.strerror))

if __name__ == '__main__':
    unittest.main()
