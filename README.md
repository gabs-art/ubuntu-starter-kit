# Setup básico servidor Ubuntu Linux

Este projeto tem como objetivo automatizar a configuração inicial de um servidor Ubuntu Linux. Ele facilita o processo de deixar seu sistema pronto para uso com configurações básicas essenciais.

---

## O que o script faz?

- Define o hostname (nome do computador na rede)
- Ajusta o fuso horário (timezone) do sistema
- Atualiza todos os pacotes instalados para as versões mais recentes
- Configura o firewall padrão (firewalld), abrindo as portas essenciais para acesso via SSH e HTTP

---

## Por que isso é importante?

Quando você instala um servidor pela primeira vez, essas configurações são fundamentais para garantir segurança, organização e funcionamento correto da máquina. Fazer isso manualmente toda vez pode ser cansativo e sujeito a erros, por isso automatizei com um script bash.

---

## Como usar

1. Faça o download do script `main.sh`.

2. Ajuste as permissões do arquivo para que possa se tornar um executavel:

   ```bash
    chmod 774 main.sh
   ```

3. Execute o mesmo:

    ```bash
    ./main.sh
   ```
