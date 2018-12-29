import unittest

from gpchart.gpbarchart import GpdbBarChart
import matplotlib as mpl
import os.path # for checking file
import os      # for removing test file
import base64  # for decoding from base64
import imghdr  # for checking image format

class TestBarChart(unittest.TestCase):

    def test_save_fig(self):
        '''
        This tests if the plot is saved with file.
        We only check whether the file is exsist and
            do not check whether the plot was drawn rightly.
        '''
        options = '''{
            "style":"fivethirtyeight",
            "figure.figsize": [13.0, 6.0],
            "legend.loc":"upper right",
            "lines.marker":"o",
            "axes.color_pallete": ["#ED553B", "#20639B", "#3CAEA3", "#F6D55C"],
            "axes.color_alpha":0.7
        }'''
        filename = "bar_unit_test_save_fig.png"
        chart = GpdbBarChart('test', options)
        chart.draw_chart([1, 2, 3, 1, 2, 3, 1, 2, 3],
                         [1, 2, 3, 4, 5, 6, 4, 2, 6],
                         ['A', 'A', 'A', 'B', 'B', 'B', 'C', 'C', 'C'],
                         [1, 1, 1, 2, 2, 2, 3, 3, 3])
        chart.save_file(filename)
        assert os.path.isfile(filename), "Plot does not saved."
        try:
            os.remove(filename)
        except OSError as e:
            print ("Error: %s - %s." % (e.filename, e.strerror))

if __name__ == '__main__':
    unittest.main()
