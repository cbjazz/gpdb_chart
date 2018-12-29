"""GPChart Library

@author cbjazz
"""

import matplotlib as mpl
import matplotlib.pyplot as plt
import matplotlib.colors as colors
import matplotlib.cm as cmx
from cycler import cycler
import json
import logging
import base64
import io
import sys

if sys.version_info < (3, 0):
    python_major_version = 2
else:
    python_major_version = 3

if python_major_version == 2:
    import StringIO

#Define chart options excpet of matplotlib
OPT_STYLE = 'style'
OPT_COLOR_MAP = 'axes.color_map'
OPT_COLOR_PALLETE = 'axes.color_pallete'
OPT_COLOR_ALPHA = 'axes.color_alpha'
OPT_PROP_CYCLE = 'axes.prop_cycle'
OPT_BAR_WIDTH = 'axes.bar_width'
OPT_BAND_COLOR = 'axes.band_color'
OPT_BAND_COLOR_ALPHA = 'axes.band_color_alpha'

non_mpl_options = [
    OPT_STYLE,
    OPT_COLOR_MAP,
    OPT_COLOR_PALLETE,
    OPT_COLOR_ALPHA,
    OPT_BAR_WIDTH,
    OPT_BAND_COLOR,
    OPT_BAND_COLOR_ALPHA
]

class GpdbChart:
    """
    This class is the top class of other charts.
    It defines the chart styles and some options.
    """

    option_dict = {}
    title = ''
    fig = None
    ax = None

    def __init__(self, title, options):
        """
        Parameters
        ----------
        title : str
            Chart title
        options : str
            Style options with json format
        """
        self.title = title
        self.option_dict = json.loads(options)

    def _set_style(self):
        if OPT_STYLE in self.option_dict.keys():
            plt.style.use(self.option_dict[OPT_STYLE])

    def _set_mpl_option(self):
        """This configs the customizing style defined from matplotlib

        The detail options refers from
            https://matplotlib.org/users/customizing.html
        """
        for key in self.option_dict.keys():
            if key not in non_mpl_options:
                try:
                    mpl.rcParams[key] = self.option_dict[key]
                except KeyError:
                    logging.warning(key + " is unknown... skip")
                except ValueError:
                    logging.warning("%s of %s unrecognize...skip"%
                        (self.option_dict[key], key))

    def set_color_map(self, value, alpha=1.0, max_color_cnt=10):
        """This creates scalar color map using gradient map.
        The name of colormap refers from
            https://matplotlib.org/examples/color/colormaps_reference.html

        Parameters
        ----------
        value : str
            The name of colormap
        alpha : float, optional (default = 1.0)
            Transparents of colors (0.0 ~ 1.0)
         max_color_cnt: int, optional (default = 10)
            The number of colors to vectorize

        RETURNS
        ----------
        list : vectorized color map
        """
        color_map = []
        color_norm = colors.Normalize(vmin=0, vmax=max_color_cnt)
        scalar_map = cmx.ScalarMappable(norm=color_norm,
                                       cmap=value)
        color_map = [scalar_map.to_rgba(i, alpha=alpha)
                     for i in range(max_color_cnt)]
        return color_map

    def _set_cycler(self, max_color_cnt=10):
        """This defines the cycler on 'axes.prop_cycle' key of matplotlib.
        Each legend of chart refers the color in this cycler sequentially.
        In here user can define colormap or color pallete.
        If user defined both, we prefer map to pallete.
        @TODO: Through cycler, we can define line style, marker and etc.
               But we only defined colors from currently version.

        Parameters
        ----------
         max_color_cnt: int, optional (default = 10)
            The number of colors to vectorize
        """
        color_map = []
        alpha = 1.0
        # Check Alpha
        if OPT_COLOR_ALPHA in self.option_dict.keys():
            alpha = self.option_dict[OPT_COLOR_ALPHA]

        # We perfer map to pallete.
        if OPT_COLOR_PALLETE in self.option_dict.keys():
            color_map = [colors.to_rgba(val, alpha=alpha)
                         for val in self.option_dict[OPT_COLOR_PALLETE]]
        elif OPT_COLOR_MAP in self.option_dict.keys():
            color_map = self.set_color_map(self.option_dict[OPT_COLOR_MAP],
                                      alpha, max_color_cnt)
        if color_map:
            mpl.rcParams[OPT_PROP_CYCLE] = cycler(color = color_map)

    def draw_chart(self, x, y, legend, sequence):
        """Abstract memthod.
        This should be implemented in subclasses.
        """
        raise NotImplementedError('Subclass must override draw_chart()!')

    def show(self):
        """
        This shows the plot on display.
        """
        plt.show()
        plt.close()

    def save_base64(self):
        """
        This encodes image to base64.

        RETURNS
        ----------
        str : base64 encoded image string
        """
        if python_major_version == 3:
            imgdata = io.BytesIO()
        else:
            imgdata = io.StringIO()
        plt.savefig(imgdata, format='png')
        plt.close()
        imgdata.seek(0)
        if python_major_version == 3:
            return base64.b64encode(imgdata.read())
        else:
            return base64.b64encode(imgdata.buf)


    def save_file(self, filename):
        """
        This stores chart to image file.

        Parameters
        ----------
         filename: str
            file path and filename with extension
        """
        self.fig.savefig(filename)
        plt.close()
