## 🪟 Guia – Configuração do Cliente OpenVPN no Windows

### ✅ Pré-requisitos

- Arquivo `cliente1.ovpn` gerado no servidor
- Porta **UDP 1194** liberada no firewall do servidor
- Cliente OpenVPN instalado no Windows

---

### 🔽 1. Instalar o OpenVPN Client

Baixe e instale o OpenVPN GUI:

🔗 [https://openvpn.net/community-downloads/](https://openvpn.net/community-downloads/)

> Escolha a versão de acordo com o seu sistema (32 ou 64 bits) e conclua a instalação normalmente.

---

### 📁 2. Adicionar Arquivo `.ovpn`

1. Transfira o arquivo `cliente1.ovpn` para o computador Windows.
2. Copie-o para o seguinte diretório:

C:\Program Files\OpenVPN\config


> 🛑 Se o Windows bloquear a cópia, execute o Explorador de Arquivos como **Administrador**.

---

### 🧑‍💼 3. Executar o OpenVPN GUI

1. No menu Iniciar, pesquise por `OpenVPN GUI`.
2. Clique com o botão direito e selecione **Executar como administrador**.
3. O ícone do OpenVPN aparecerá na bandeja do sistema (perto do relógio).

---

### 🔌 4. Conectar-se à VPN

1. Clique com o botão direito no ícone do OpenVPN na bandeja.
2. Selecione a opção: **cliente1 > Conectar**.
3. Pronto! Você estará conectado à VPN se tudo estiver correto.

---

### 🧪 5. Testes

#### ✔️ Verificar IP

Abra o terminal (cmd) e digite:

ipconfig


> Verifique se há um adaptador chamado **TAP-Windows Adapter** com IP na faixa `10.8.0.x`.

#### ✔️ Testar comunicação com o servidor VPN

ping 10.8.0.1 


> Se houver resposta, a VPN está funcionando corretamente.

---

### ❌ Solução de Problemas

| Problema              | Causa Comum                         | Solução                                        |
|-----------------------|--------------------------------------|------------------------------------------------|
| `AUTH_FAILED`         | Certificado inválido ou ausente      | Verifique o `.ovpn` ou gere novamente          |
| `TLS Error`           | Chave `ta.key` incorreta ou ausente | Corrija ou regenere o arquivo `.ovpn`          |
| Não conecta à VPN     | Porta UDP 1194 bloqueada             | Libere a porta no firewall/roteador            |
| OpenVPN não abre      | Falta de permissões                  | Execute como **Administrador**                 |

---

### 🌐 DNS Dinâmico (Opcional)

Se o servidor tiver IP dinâmico, use um serviço de DNS dinâmico:

- [No-IP](https://www.noip.com/)
- [DuckDNS](https://www.duckdns.org/)

No arquivo `.ovpn`, substitua o IP pelo nome DNS:

```ini
remote meuvpn.duckdns.org 1194



