# 맥북에 mavros 네이티브로 설치하기

## 사용방법

- 먼저 https://github.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon 를 이용해 ROS2 Jazzy와 Gazebe 설치를 완료한다.
  
  ```bash
  # ROS2 Jazzy와 Gazebo 설치 스크립트 (이미 실행했다면 필요없음)
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon/main/install.sh)"
  ```

  - 완료하면 `$HOME/.ros2_jazzy_install_config`에 설치된 ROS2 Jazzy와 Gazebo의 경로가 저장된다. (기본경로는 `ros2_jazzy`, `gz_harmonic`)
  - `cat $HOME/.ros2_jazzy_install_config`로 config파일 내용 확인
- 이제 mavros를 설치하기 위해 다음과 같이 진행한다.

```bash
# mavros 설치 스크립트
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/IOES-Lab/ROS2_MAVROS_AppleSilicon/main/install.sh)"
```


## Notes

- USB 연결 포트 찾기

  ```bash
  system_profiler SPUSBDataType | awk '/ArduPilot/{found=1} found && /Location ID/{print "/dev/cu.usbmodem" int(substr($3,3,3) "01"); found=0}'
  ```