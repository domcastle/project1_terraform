############################################################
# 1. VPC 및 Subnet 조회 (Name 태그 기반)
############################################################

# 1-1. VPC 조회
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.target_vpc_name] # 예: justic_vpc
  }
}

# 1-2. Subnet 조회 (VPC ID 종속)
# var.target_subnet_id를 쓰지 않고, 이름으로 찾아낸 ID를 사용하기 위함
data "aws_subnet" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.target_subnet_name] # 예: justic_private_subnet
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id] # 위에서 찾은 VPC 내에서만 검색
  }
}

############################################################
# 2. 기존 리소스 조회 (NAT Gateway, Route Table)
############################################################

# 2-1. NAT Gateway 조회
data "aws_nat_gateway" "existing" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  filter {
    name   = "tag:Name"
    values = [var.nat_name] # 예: justic_nat
  }
  state = "available"
}

# 2-2. Route Table 조회
data "aws_route_table" "target_rt" {
  vpc_id = data.aws_vpc.selected.id

  filter {
    name   = "tag:Name"
    values = [var.target_rt_name] # 예: justic_private_rt
  }
}

############################################################
# 3. 리소스 생성 및 연결 (Route 추가, Subnet 연결)
############################################################


# 3-2. Private Subnet을 기존 Route Table에 연결
resource "aws_route_table_association" "private_association" {
  # 중요: 변수로 받은 ID가 아니라, data로 찾아낸 ID를 사용
  subnet_id      = data.aws_subnet.selected.id
  route_table_id = data.aws_route_table.target_rt.id
}