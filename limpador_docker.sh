#!/usr/bin/env bash

# Função para exibir mensagens de log
log_info() {
  echo -e "\e[1;34mINFO:\e[0m $1"
}

log_success() {
  echo -e "\e[1;32mSUCESSO:\e[0m $1"
}

log_error() {
  echo -e "\e[1;31mERRO:\e[0m $1"
  exit 1
}

log_warn() {
  echo -e "\e[1;33mAVISO:\e[0m $1"
}

log_info "INICIANDO LIMPEZA DO AMBIENTE DOCKER..."

# Verificar se o Docker está instalado
if ! command -v docker &> /dev/null
then
    log_warn "DOCKER NÃO ENCONTRADO. INSTALE O DOCKER PRIMEIRO USANDO O SCRIPT DE INSTALAÇÃO."
    exit 0
fi

log_info "DOCKER ENCONTRADO. INICIANDO LIMPEZA..."

# Parar e remover todos os containers Docker
log_info "PARANDO E REMOVENDO TODOS OS CONTAINERS DOCKER..."
if docker ps -aq | grep -q .
then
  docker stop $(docker ps -aq) 2>/dev/null || log_warn "NÃO FOI POSSÍVEL PARAR TODOS OS CONTAINERS."
  docker rm $(docker ps -aq) 2>/dev/null || log_warn "NÃO FOI POSSÍVEL REMOVER TODOS OS CONTAINERS."
else
  log_info "NENHUM CONTAINER ATIVO OU INATIVO PARA PARAR/REMOVER."
fi
log_success "CONTAINERS VERIFICADOS/REMOVIDOS."

# Remover todos os volumes Docker
log_info "REMOVENDO TODOS OS VOLUMES DOCKER..."
if docker volume ls -q | grep -q .
then
  docker volume prune -f 2>/dev/null || log_warn "NÃO FOI POSSÍVEL REMOVER TODOS OS VOLUMES."
else
  log_info "NENHUM VOLUME PARA REMOVER."
fi
log_success "VOLUMES VERIFICADOS/REMOVIDOS."

# Remover todas as redes Docker
log_info "REMOVENDO TODAS AS REDES DOCKER..."
if docker network ls -q | grep -q .
then
  docker network prune -f 2>/dev/null || log_warn "NÃO FOI POSSÍVEL REMOVER TODAS AS REDES."
else
  log_info "NENHUMA REDE PARA REMOVER."
fi
log_success "REDES VERIFICADAS/REMOVIDAS."

# Remover todas as imagens Docker
log_info "REMOVENDO TODAS AS IMAGENS DOCKER..."
if docker images -aq | grep -q .
then
  docker rmi -f $(docker images -aq) 2>/dev/null || log_warn "NÃO FOI POSSÍVEL REMOVER TODAS AS IMAGENS."
else
  log_info "NENHUMA IMAGEM PARA REMOVER."
fi
log_success "IMAGENS VERIFICADAS/REMOVIDAS."

log_success "LIMPEZA DO AMBIENTE DOCKER CONCLUÍDA!"
log_info "AGORA VOCÊ PODE EXECUTAR O SCRIPT DE INSTALAÇÃO DO SERVIDOR DE MONITORAMENTO."

