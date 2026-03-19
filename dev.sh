#!/bin/bash

PROJECT_NAME="Sistema Escolar"

BACKEND_DIR="backend"
FLUTTER_DIR="mobile/escola_app"

PORT=3000
WEB_PORT=8080

LOG_DIR="logs"
PID_DIR=".pids"

BACKEND_PID_FILE="$PID_DIR/backend.pid"
FLUTTER_PID_FILE="$PID_DIR/flutter.pid"

# ==============================
# CORES
# ==============================

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# ==============================
# SETUP
# ==============================

setup() {

mkdir -p "$LOG_DIR"
mkdir -p "$PID_DIR"

}

# ==============================
# HEADER
# ==============================

header() {

echo ""
echo -e "${CYAN}=================================${NC}"
echo -e "${CYAN}   $PROJECT_NAME DEV TOOL${NC}"
echo -e "${CYAN}=================================${NC}"
echo ""

}

# ==============================
# MATAR PROCESSOS ANTIGOS
# ==============================

kill_old_processes() {

echo -e "${YELLOW}Limpando processos antigos...${NC}"

pkill -f "node" 2>/dev/null
pkill -f "flutter" 2>/dev/null
pkill -f "chrome" 2>/dev/null

sleep 1

}

# ==============================
# LIBERAR PORTA
# ==============================

free_port() {

PID=$(lsof -t -i:$PORT)

if [ ! -z "$PID" ]; then
    echo -e "${YELLOW}Liberando porta $PORT${NC}"
    kill $PID 2>/dev/null
fi

PID_WEB=$(lsof -t -i:$WEB_PORT)

if [ ! -z "$PID_WEB" ]; then
    echo -e "${YELLOW}Liberando porta $WEB_PORT${NC}"
    kill $PID_WEB 2>/dev/null
fi

}

# ==============================
# CHECK TOOLS
# ==============================

check_tools() {

for cmd in node npm flutter; do
    if ! command -v $cmd &> /dev/null
    then
        echo -e "${RED}Falta instalar: $cmd${NC}"
        exit 1
    fi
done

}

# ==============================
# CHECK DIRS
# ==============================

check_dirs() {

if [ ! -d "$BACKEND_DIR" ]; then
  echo -e "${RED}Pasta backend não encontrada${NC}"
  exit 1
fi

if [ ! -d "$FLUTTER_DIR" ]; then
  echo -e "${RED}Pasta flutter não encontrada${NC}"
  exit 1
fi

}

# ==============================
# START BACKEND
# ==============================

start_backend() {

echo -e "${GREEN}Iniciando Backend...${NC}"

cd "$BACKEND_DIR" || exit

if [ ! -d "node_modules" ]; then
  echo -e "${BLUE}Instalando dependências...${NC}"
  npm install
fi

npm run start:dev > "../$LOG_DIR/backend.log" 2>&1 &

BACK_PID=$!

echo $BACK_PID > "../$BACKEND_PID_FILE"

cd ..

echo -e "${GREEN}Backend rodando → http://localhost:$PORT${NC}"

}

# ==============================
# START FLUTTER
# ==============================

start_flutter() {

echo -e "${GREEN}Iniciando Flutter...${NC}"

cd "$FLUTTER_DIR" || exit

flutter pub get > /dev/null 2>&1

flutter run -d chrome --web-port $WEB_PORT > "../../$LOG_DIR/flutter.log" 2>&1 &

FLUT_PID=$!

echo $FLUT_PID > "../../$FLUTTER_PID_FILE"

cd ../..

echo -e "${GREEN}Flutter → http://localhost:$WEB_PORT${NC}"

}

# ==============================
# OPEN BROWSER
# ==============================

open_browser() {

URL="http://localhost:$WEB_PORT"

if command -v xdg-open &> /dev/null; then
  xdg-open $URL
elif command -v open &> /dev/null; then
  open $URL
fi

}

# ==============================
# DEV MODE
# ==============================

dev_mode() {

header
setup
check_tools
check_dirs

kill_old_processes
free_port

start_backend

sleep 2

start_flutter

sleep 4

open_browser

echo ""
echo -e "${GREEN}Ambiente DEV iniciado${NC}"
echo ""

}

# ==============================
# STOP
# ==============================

stop_system() {

echo -e "${RED}Parando sistema...${NC}"

kill_old_processes
free_port

rm -f "$BACKEND_PID_FILE"
rm -f "$FLUTTER_PID_FILE"

echo "Sistema parado"

}

# ==============================
# STATUS
# ==============================

status() {

echo ""
echo -e "${CYAN}STATUS${NC}"
echo ""

echo "Backend:"
lsof -i:$PORT

echo ""
echo "Flutter:"
lsof -i:$WEB_PORT

echo ""

}

# ==============================
# LOGS
# ==============================

logs() {

echo ""
echo "Backend logs:"
echo "tail -f logs/backend.log"

echo ""
echo "Flutter logs:"
echo "tail -f logs/flutter.log"

}

# ==============================
# COMMANDS
# ==============================

case "$1" in

dev)
dev_mode
;;

stop)
stop_system
;;

status)
status
;;

logs)
logs
;;

*)
echo ""
echo "./dev.sh dev    → iniciar ambiente"
echo "./dev.sh stop   → parar tudo"
echo "./dev.sh status → ver portas"
echo "./dev.sh logs   → ver logs"
echo ""
;;

esac