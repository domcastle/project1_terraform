resource "aws_security_group" "ai_sg" {
  name        = "ai-worker-sg"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Ollama API from VPC"
    from_port   = 11434
    to_port     = 11434
    protocol    = "tcp"
    # [수정 권장] 기존 ROSA 워커 노드들이 이 인스턴스에 접속해야 하므로 
    # VPC CIDR 전체를 허용하는 현재 설정은 적절합니다.
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  # 만약 외부(내 로컬)에서 직접 Ollama API를 때려보고 싶다면 
  # Public 서브넷에 띄우고 아래와 같이 본인 IP를 추가해야 합니다.
  # (현재는 Private 서브넷이므로 VPC 내부 통신 전용입니다)

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ai_worker" {
  count = var.enable_ai_worker ? 1 : 0

  ami           = data.aws_ami.ubuntu.id
  instance_type = "g4dn.xlarge"
  
  # [확인] 이미지 속 서브넷이 2a(private)인지 확인하세요.
  # module.vpc.private_subnets[0]이 ap-northeast-2a에 해당한다면 그대로 두시면 됩니다.
  subnet_id     = module.vpc.private_subnets[0]

  # [추가 권장] GPU 인스턴스는 스팟 종료가 빈번할 수 있습니다.
  # 인스턴스가 띄워질 때 자동으로 공인 IP를 할당받지 않도록(Private 서브넷이므로) 설정 확인
  associate_public_ip_address = false

  instance_market_options {
    market_type = "spot"
    spot_options {
      max_price = "0.20" 
      instance_interruption_behavior = "terminate"
    }
  }

  vpc_security_group_ids = [aws_security_group.ai_sg.id]
  
  root_block_device {
    volume_size = 100
    volume_type = "gp3"
  }

  # [User Data 최적화]
  user_data = <<-SHELL
              #!/bin/bash
              # 드라이버 설치 시 팝업 방지
              export DEBIAN_FRONTEND=noninteractive
              apt-get update
              apt-get install -y ubuntu-drivers-common
              
              # G4dn 인스턴스(NVIDIA T4)용 드라이버 설치
              ubuntu-drivers autoinstall
              
              # Ollama 설치
              curl -fsSL https://ollama.com/install.sh | sh
              
              # Ollama 외부 접속 허용 설정 (VPC 내부 다른 노드들이 접속할 수 있게)
              mkdir -p /etc/systemd/system/ollama.service.d
              cat <<EOF > /etc/systemd/system/ollama.service.d/override.conf
              [Service]
              Environment="OLLAMA_HOST=0.0.0.0:11434"
              EOF
              
              systemctl daemon-reload
              systemctl enable ollama
              systemctl restart ollama
              
              # 모델 다운로드 (GPU 드라이버 로드 시간을 고려해 약간 대기)
              sleep 30
              ollama pull qwen2.5-vl
              SHELL

  tags = {
    Name = "ai-worker-spot"
  }
}