#
# This file is autogenerated during plugin quickstart and overwritten during
# plugin makedist. DO NOT CHANGE IT if you plan to use plugin makedist to update 
# the distribution.
#

from setuptools import setup, find_packages

kwargs = {'author': 'Tom Bancroft',
 'author_email': '',
 'classifiers': ['Intended Audience :: Science/Research',
                 'Topic :: Scientific/Engineering'],
 'description': 'OpenMDAO Component plugin for wrapping OpenModelica model',
 'download_url': '',
 'entry_points': '[openmdao.component]\nommodelwrapper.ommodelwrapper.OMModelWrapper=ommodelwrapper.ommodelwrapper:OMModelWrapper\n\n[openmdao.container]\nommodelwrapper.ommodelwrapper.OMModelWrapper=ommodelwrapper.ommodelwrapper:OMModelWrapper',
 'include_package_data': True,
 'install_requires': ['openmdao.main'],
 'keywords': ['openmdao, OpenModelica, Modelica'],
 'license': 'GNU General Public License, version 2',
 'maintainer': 'Kyungjin Moon',
 'maintainer_email': 'kyungjin.moon@asdl.gatech.edu',
 'name': 'ommodelwrapper',
 'package_data': {'ommodelwrapper': ['sphinx_build/html/index.html',
                                     'sphinx_build/html/.buildinfo',
                                     'sphinx_build/html/py-modindex.html',
                                     'sphinx_build/html/objects.inv',
                                     'sphinx_build/html/searchindex.js',
                                     'sphinx_build/html/search.html',
                                     'sphinx_build/html/pkgdocs.html',
                                     'sphinx_build/html/usage.html',
                                     'sphinx_build/html/genindex.html',
                                     'sphinx_build/html/srcdocs.html',
                                     'sphinx_build/html/_sources/usage.txt',
                                     'sphinx_build/html/_sources/pkgdocs.txt',
                                     'sphinx_build/html/_sources/index.txt',
                                     'sphinx_build/html/_sources/srcdocs.txt',
                                     'sphinx_build/html/_static/plus.png',
                                     'sphinx_build/html/_static/comment-bright.png',
                                     'sphinx_build/html/_static/comment.png',
                                     'sphinx_build/html/_static/down-pressed.png',
                                     'sphinx_build/html/_static/sidebar.js',
                                     'sphinx_build/html/_static/doctools.js',
                                     'sphinx_build/html/_static/ajax-loader.gif',
                                     'sphinx_build/html/_static/default.css',
                                     'sphinx_build/html/_static/down.png',
                                     'sphinx_build/html/_static/jquery.js',
                                     'sphinx_build/html/_static/underscore.js',
                                     'sphinx_build/html/_static/minus.png',
                                     'sphinx_build/html/_static/up-pressed.png',
                                     'sphinx_build/html/_static/up.png',
                                     'sphinx_build/html/_static/pygments.css',
                                     'sphinx_build/html/_static/searchtools.js',
                                     'sphinx_build/html/_static/file.png',
                                     'sphinx_build/html/_static/basic.css',
                                     'sphinx_build/html/_static/websupport.js',
                                     'sphinx_build/html/_static/comment-close.png',
                                     'sphinx_build/html/_modules/index.html',
                                     'sphinx_build/html/_modules/ommodelwrapper/load_modelica_mat.html',
                                     'sphinx_build/html/_modules/ommodelwrapper/ommodelwrapper.html',
                                     'sphinx_build/html/_modules/ommodelwrapper/OM_build.html',
                                     'test/test_ommodelwrapper.py',
                                     'test/SimAcceleration.mo',
                                     'test/VehicleDesign.mo']},
 'package_dir': {'': 'src'},
 'packages': ['ommodelwrapper'],
 'url': '',
 'version': '0.2',
 'zip_safe': False}


setup(**kwargs)

