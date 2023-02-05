import cminx
cminx.main(['-o', './generated/CMinx', '-r', '../cmake'])

project = 'monProjet'
copyright = '2023, monAuteur'
author = 'monAuteur'
release = '111'

extensions = []

templates_path = ['_templates']
exclude_patterns = []

html_theme = 'alabaster'
html_static_path = ['_static']
