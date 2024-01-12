#  PoseModel on iOS

- Pose Model을 Native Swift 베이스로 구현하고자 함

## Current Trying Logic

- Get Original Image (Arbitary Resolution)

- Resizing to fit with Input Tensor dimensions

    - Ignore original image's width-height ratio
    
    - a.k.a 찌그러뜨리기

- Invoiing the Model

- Restore coordinates

## Failure log

- Trial 0.1 `CoreML` `ML Package` : Not uploaded on my Github

    - Apple에서 AI Model을 돌리기 위해 추천하는, CoreML을 사용하고자 함
    
    - `coremltools` Python 라이브러리를 이용하면, `.pb` `.h5` 등의 모델 파일을 CoreML을 위한 ML Package로 변환 가능
    
    - **Problem**: 그러나, 포즈모델의 모델 파일을 구할 수 없음
    
        - `.pbtxt` `.tflite` 정도만 구할 수 있었음
    
        - 해당 파일들은 모델 파일이 아닌, "trained model" 로, `coremltools`와 호환되지 않는 것으로 보임
        
- Trial 1.0 `TensorFlowLite` `Swift` : Not uploaded on my Github

    - QuickPose, PoseNet 프로젝트처럼 `TensorFlowLite`를 iOS에서 사용하는 방법을 시도
    
    - TensorFlowLite로 `allocateTensors()`를 실행, 각 텐서의 Dimensions를 확인
    
        - PoseNet과 Tensor 형태가 사뭇 다름을 확인
        
    - InputTensor에 맞는 preprocessor를 구성하고, invoking하여 HeatsTensor(output)을 출력
    
    - Output Tensor가 39개 노드에 대한 좌표 정보임을 확인함
    
        - Float32 형태로 Array를 펴고, 복사한 후, 외부 Python 프로젝트에서 그래프를 그려 확인함
        
    - **Problem**: 그러나, InputTensor를 위한 preprocessor가 이미지를 크롭하고 있었음
    
        - InputTensor(256 by 256)에 맞게 변환하기 위해, 기존 이미지를 정방형으로 자르고, 다운사이징함
        
        - 크롭되는 부분에 사람이 있다면 오인식이 일어남
        
        - 이미지를 찌그러뜨려 접근하는 방법을 시도하려다가, 포기함
            
            - 정확도가 낮아질 우려가 있음
            
            - 비율을 무시하고 resizing하는 built-in function을 찾지 못함
        
        - 이미지 밖에 여백(검정 픽셀)을 채워넣어, 정방형으로 만들고 다운사이징하는 로직을 시도함
        
            - 구현에 성공함
            
            - 그러나, 오인식률이 너무 높아짐
            
                - 추정 원인: 검정색 픽셀로 채워진 그림은 모델이 Train 된 환경이 아님
            
- Trial 2.0 `Object Detection` `Swift` [Repository](https://github.com/hajun-myoung/posemodel_test2)

    - Object Detection으로 "human" object를 탐색 ➡️ 해당 Object 근처 정방형 크롭 ➡️ PoseModel Invoking 순서로 구현해보고자 함
    
    - MediaPipe 공식 문서를 참조, Object Detection 구현에 성공
    
        - ![Object Detcted Demo](./human_detected_ios.png)
        
    - **Problem**: `TensorFlowLite` 설치 실패
    
        - MediaPipe Object Detection을 쓰기 위한 Pods 라이브러리 `MediapipeVisionTasks`와 충돌
        
        - 빌드 실패
        
        - Object Detection도 `.tflite` Trained Model을 직접 읽는 방식을 시도함
        
            - Model Invoking까지 성공했으나, 결과 해석에 실패함
            
            - Output Tensor의 Dimension이 (1, 19206, 4)으로, 매우 큼
            
                - 해당 Tensor는 라벨링 없이, Float32 형태의 데이터만 나열되어 있음
            
                - 19,206개의 Segmentation 가능한 Object 종류 + 4개의 좌표 정보(x, y, widht, height)로 추정
                
                - 그러나 19,206개의 Object Indexing Table을 찾지 못함
            
            - 오버 테크놀로지라는 판단으로, 중단함

