from setuptools import setup
setup(
name='xblock-codeditor',
version='0.1',
description='codeditor XBlock',
py_modules=['codeditor'],
install_requires=['XBlock'],
entry_points={
'xblock.v1': [
'codeditor = codeditoffr:CodeEditorBlock',
]
}
)
