############################################################
# 1. Ubuntu 22.04 AMI 찾기
############################################################
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

############################################################
# 2. 보안 그룹 (SSH + Ollama 포트 개방)
############################################################
resource "aws_security_group" "ai_sg" {
  name        = "ai-worker-sg"
  description = "Security group for AI Worker"
  
  # main.tf (또는 vpc.tf)에서 찾아둔 VPC ID 사용
  vpc_id      = data.aws_vpc.selected.id 

  # Ollama API (11434)
  ingress {
    description = "Ollama API"
    from_port   = 11434
    to_port     = 11434
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  # SSH (22)
  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  # 아웃바운드 (인터넷 연결 필수)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################################################
# 3. EC2 인스턴스 생성
############################################################
resource "aws_instance" "ai_worker" {
  count = var.enable_ai_worker ? 1 : 0

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.xlarge" # vCPU 4, RAM 16GB
  
  # [수정됨] 변수로 받은 ID가 아니라, 이름으로 찾아낸 Subnet ID 사용
  subnet_id     = data.aws_subnet.selected.id
  
  key_name      = "myaikeypair"

  vpc_security_group_ids      = [aws_security_group.ai_sg.id]
  associate_public_ip_address = true 

  root_block_device {
    volume_size = 50 
    volume_type = "gp3"
  }

  # ---------------------------------------------------------
  # [핵심] 스마트 설치 스크립트 (HOME 변수 에러 수정됨)
  # ---------------------------------------------------------
  user_data = <<-SHELL
              #!/bin/bash
              
              # 로그 파일 설정
              LOGfile="/var/log/ollama-install.log"
              exec > >(tee -a $LOGfile) 2>&1
              
              echo ">>> [1/5] 기본 설정 시작..."
              echo "ubuntu:soldesk1." | chpasswd
              sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
              sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
              systemctl restart ssh
              
              echo ">>> [2/5] 필수 패키지 설치..."
              export DEBIAN_FRONTEND=noninteractive
              apt-get update
              apt-get install -y curl
              
              echo ">>> [3/5] Ollama 설치 시작..."
              curl -fsSL https://ollama.com/install.sh | sh
              
              # 외부 접속(0.0.0.0) 허용 설정
              mkdir -p /etc/systemd/system/ollama.service.d
              cat <<EOF > /etc/systemd/system/ollama.service.d/override.conf
              [Service]
              Environment="OLLAMA_HOST=0.0.0.0:11434"
              EOF
              
              systemctl daemon-reload
              systemctl restart ollama
              
              echo ">>> [4/5] Ollama 서비스 대기 중 (Wait Loop)..."
              count=0
              until curl -s -f http://localhost:11434/api/tags > /dev/null; do
                  echo "Waiting for Ollama API... ($count)"
                  sleep 5
                  count=$((count+1))
                  if [ "$count" -ge 60 ]; then echo "Timeout waiting for Ollama"; break; fi
              done
              
              echo ">>> Ollama 준비 완료! 모델 다운로드 시작..."
              echo ">>> [5/5] 모델 다운로드 (qwen2.5vl)..."
              
              # cloud-init 환경변수 HOME 설정
              export HOME=/root
              
              for i in {1..3}; do
                  echo "Downloading model... Attempt $i"
                  if ollama pull qwen2.5vl; then
                      echo ">>> 모델 다운로드 성공!"
                      break
                  fi
                  echo ">>> 다운로드 실패. 5초 후 재시도..."
                  sleep 5
              done
              
              echo ">>> 모든 설치 완료! 즐거운 AI 되세요."
              SHELL

  tags = {
    Name = "ai-worker-cpu"
  }
}