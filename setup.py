# Scaffolding

from setuptools import setup

with open("README.md", "r") as fh:
    long_description = fh.read()

setup(name='thothclient',
      version='0.1',
      description='User client for thothbackup',
      long_description=long_description,
      long_description_content_type="text/markdown",
      url='https://github.com/zyradyl/thothclient',
      author='Zyradyl',
      author_email='nmspencer89@outlook.com',
      license='ISC',
      packages=['thothclient'],
      classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: ISC License",
        "Operating System :: OS Independent",
      ])
