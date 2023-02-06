import cminx

cminx.main(['-o', './generated/CMinx', '-r', '../cmake'])

project = 'CMMM'
copyright = ''
author = ''
release = '0.1'

extensions = []

templates_path = ['templates']
exclude_patterns = []

html_theme = 'alabaster'
html_static_path = ['static']
