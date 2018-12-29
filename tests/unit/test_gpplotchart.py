import unittest

from gpchart.gpplotchart import GpdbPlotChart
import matplotlib as mpl
import os.path # for checking file
import os      # for removing test file
import base64  # for decoding from base64
import imghdr  # for checking image format

class TestPlotChart(unittest.TestCase):
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
            "lines.marker":"o",
            "axes.color_map":"PuOr",
            "axes.color_alpha":0.7
        }'''
        filename = "plot_unit_test.png"
        chart = GpdbPlotChart('test', options)
        chart.draw_chart([1,2,3], [1,2,3], ['A', 'A', 'A'], [1,1,1])
        chart.save_file(filename)
        assert os.path.isfile(filename), "Plot does not saved."
        try:
            os.remove(filename)
        except OSError as e:
            print ("Error: %s - %s." % (e.filename, e.strerror))

    def test_encode_fig(self):
        '''
        This tests if the plot is saved with file.
        We only check whether the file is exsist and
            do not check whether the plot was drawn rightly.
        '''
        options = '''{
            "style":"bmh",
            "figure.figsize": [12.0, 6.0],
            "legend.loc":"upper right",
            "lines.marker":"o",
            "axes.color_map":"PuOr",
            "axes.color_alpha":0.7
        }'''
        filename = "plot_unit_test.png"
        chart = GpdbPlotChart('test', options)
        chart.draw_chart([1,2,3], [1,2,3], ['A', 'A', 'A'], [1,1,1])
        result = chart.save_base64()

        with open(filename, "wb") as fh:
            fh.write(base64.decodebytes(result))
        assert os.path.isfile(filename), "Plot does not saved."
        assert imghdr.what(filename) == 'png', \
            "The plot was failed to encod to 'png'"
        try:
            os.remove(filename)
        except OSError as e:
            print ("Error: %s - %s." % (e.filename, e.strerror))


if __name__ == '__main__':
    unittest.main()
