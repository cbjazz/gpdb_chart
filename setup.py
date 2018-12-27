import pathlib
from setuptools import setup

HERE = pathlib.Path(__file__).parent

README = (HERE / "README.md").read_text()

requirements = [
	'numpy', 'pandas', 'matplotlib'
]

setup(
	name='gpchart',
	version='0.0.1',
	description='Chart creator for GPDB',
	long_description=README,
	long_description_content_type="text/markdown",
	author='Changbai Choi',
	author_email='cbjazz77@gmail.com',
	url ='https://github.com/cbjazz/gpdb_chart',
	download_url='https://github.com/cbjazz/gpdb_chart.git',
	license='MIT',
	packages=["gpchart"],
	install_requires=requirements,
	entry_points={
    	'console_scripts': [
        		'gpchart=gpchart.__main__:main',
        	],
        },
	classifiers=[
        'Development Status :: 1 - Alpha',
        'License :: OSI Approved :: MIT License',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3.6',
      ],
	zip_safe=False
)
