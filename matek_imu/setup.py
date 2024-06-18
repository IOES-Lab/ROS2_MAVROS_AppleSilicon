import os
from glob import glob
from setuptools import find_packages, setup

package_name = 'matek_imu'

setup(
    name=package_name,
    version='0.0.0',
    packages=find_packages(exclude=['test']),
    data_files=[
        ('share/ament_index/resource_index/packages',
            ['resource/' + package_name]),
        ('share/' + package_name, ['package.xml']),
        # include all launch files
        (os.path.join('share', package_name, 'launch'), glob(os.path.join('launch', '*.launch')))
    ],
    install_requires=[
        'setuptools',
        'angles',
        'control_toolbox',
        'eigen_conversions',
        'geometry_msgs',
        'mavros',
        'std_msgs',
        'tf2_ros'
        ],
    zip_safe=True,
    maintainer='woensug',
    maintainer_email='woensug.choi@gmail.com',
    description='TODO: Package description',
    license='TODO: License declaration',
    tests_require=['pytest'],
    entry_points={
        'console_scripts': [
        ],
    },
)
