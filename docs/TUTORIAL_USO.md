# Contábil ERP — como usar (tutorial com exercício)

## 1. O fluxo do sistema

```
  CADASTROS (você)          MOVIMENTOS (você)              O SISTEMA FAZ SOZINHO              CONSULTAS (você lê)
  ----------------          -----------------              ---------------------              -------------------
  Plano de contas   ──┐     Compra ───────────────┐        • atualiza o saldo por prateleira  Saldo de estoque
  Clientes/fornec.  ──┤     Consumo ──────────────┤        • recalcula o custo médio          Custo por veículo
  Itens/serviços    ──┤     Transferência ────────┼──────► • gera o lançamento contábil  ───► Diário (por período)
  Unidades          ──┼──►  Prestação de serviço ─┤        • tudo numa transação              Razonete (conta em T)
  Locais de estoque ──┤     Manutenção de veículo ┘                                           Balancete (+ FastReport)
  Veículos          ──┘                                                                       Resumo patrimonial
                            Lançamento contábil manual ──► valida D = C, só contas analíticas
                            (dinheiro: aporte, pagamentos, recebimentos, salários)
```

**A ideia central:** o que tem **item** (produto, serviço ou peça e mão de obra de um veículo) passa por *Movimentos*, e a contabilidade é feita sozinha. O que é **só dinheiro** (aporte de capital, pagar um fornecedor, receber de um cliente, salário) passa por *Lançamento contábil*, porque o sistema não tem módulo financeiro.

## 2. O que é automático e o que é manual

| O sistema faz sozinho | Você faz manualmente |
|---|---|
| Cria o banco e os dados iniciais na primeira execução | Os cadastros (entidades, itens, unidades, locais, veículos, contas novas) |
| Confere a senha (hash) e habilita os menus pelo perfil | Login; o admin cria usuários e perfis |
| **Gera o lançamento contábil** de compra, consumo, serviço e manutenção | Registrar o **movimento** (o que entrou, saiu ou mudou de lugar) |
| Escolhe a contrapartida: à vista → Bancos; a prazo → Fornecedores ou Clientes | Dizer se foi à vista ou a prazo |
| Recalcula o **custo médio** a cada compra de produto | Informar o valor unitário da compra |
| Dá baixa nas saídas (consumo, peças da manutenção) **pelo custo médio** | Escolher a conta de despesa |
| Mostra só as prateleiras que têm o item, com a quantidade de cada uma | Escolher a prateleira de origem e/ou de destino |
| Bloqueia saída sem saldo e desfaz tudo (rollback) se algo falhar | — |
| Não gera lançamento na transferência (o patrimônio não muda) | — |
| Soma o custo de cada veículo (peças + mão de obra) | Escolher o veículo na manutenção |
| Formata o CPF/CNPJ enquanto você digita e confere os dígitos verificadores | Digitar o documento |
| Na tela de lançamento: soma D e C, mostra a diferença e sugere o que falta | Lançamentos só de dinheiro |

## 3. Como cada tipo de tela funciona

**Telas de cadastro** (Clientes e fornecedores, Itens, Locais, Veículos, Plano de contas, Unidades, Usuários)
- A grade em cima lista os registros. Ao clicar numa linha, os campos de baixo mostram o registro.
- A barra de botões no topo é o **navegador**: ⏮ ◀ ▶ ⏭ navegam; **+** inclui; **−** exclui; **▲** edita; **✓** salva; **✗** cancela; **↻** atualiza. Passe o mouse para ver o nome de cada um.
- **Para incluir:** clique em **+**. O cursor vai sozinho para o primeiro campo, e a grade fica bloqueada até você salvar (✓) ou cancelar (✗).
- **Para alterar:** selecione a linha na grade e clique em **▲**. Os campos ficam travados até você clicar em + ou ▲, para ninguém alterar um registro sem querer.
- Fechar com alteração pendente faz a tela perguntar se quer salvar.

**Lançamento contábil** (*Movimentos › Lançamento contábil*)
1. Preencha a data e o **histórico**: o texto que explica o fato, por exemplo "Pagamento da NF 1234 à Distribuidora Rodas". É ele que aparece no Diário e no razonete.
2. Para cada partida: escolha a conta, marque Débito ou Crédito, digite o valor e clique em **Adicionar** (ou Enter).
3. A diferença fica **vermelha** até D = C e **verde** quando fecha. O lado e o valor da próxima partida já vêm sugeridos.
4. **Gravar** só habilita com D = C e pelo menos 2 partidas.
5. O botão **Ver lançamentos...** abre o **Diário**, com o filtro **De / Até**.

**Movimentos** (*Movimentos › Compra / Consumo / Transferência / Prestação de serviço / Manutenção de veículo*)
1. Cabeçalho: data; fornecedor ou cliente e pagamento; conta de despesa (consumo e manutenção); veículo (manutenção); observação.
2. Para cada item: escolha o item. Na **origem** aparecem **só as prateleiras que têm esse item, com a quantidade disponível**; se houver só uma, ela já vem escolhida. Informe a quantidade (e o valor, quando pedir) e clique em **Adicionar**.
3. Ao clicar em **Gravar**, a mensagem informa o número do movimento e o do lançamento gerado.

**Consultas:** abrem já calculadas; o botão **Atualizar** recalcula.

## 4. Exercício guiado: "Auto Center"

Comece do zero:
1. Feche o app e apague `banco\contabil.db`. O banco é recriado com o seed novo (veículos e permissões por operação).
2. Entre como **admin**.

> Para refazer depois, use *Sistema › Demonstração › Zerar movimentos* e **pule a Parte 1**: os cadastros continuam lá.

### Parte 1 — Cadastros (manual)

**1.1** *Cadastros › Clientes e fornecedores* › **+**
- Nome: `Distribuidora Rodas Ltda`
- CPF/CNPJ: digite só os números `12345678000195` e veja a máscara aparecer: **12.345.678/0001-95**
- Marque **Fornecedor** › **✓**

**1.2** **+** de novo
- Nome: `Maria Souza` · CPF/CNPJ: `12345678909` (vira 123.456.789-09) · marque **Cliente** › **✓**
- *Teste:* troque o CPF para `12345678900` e salve → "CPF/CNPJ inválido: os dígitos verificadores não conferem." Volte para `12345678909`.
- *Teste:* inclua um registro só com o nome e salve → "Marque se é cliente, fornecedor ou os dois." Depois cancele com ✗.

**1.3** *Cadastros › Locais de estoque* › **+**
- Código: `ALM.3A` · Nome: `Prateleira 3A` · Local pai: **Almoxarifado Central** · "Aceita estoque" marcado › **✓**

**1.4** *Cadastros › Itens e serviços* › **+**
- Código: `FILTRO-OL` · Descrição: `Filtro de óleo` · Tipo: **Produto** · Unidade: **PC** · Conta: **Estoques** (já vem sugerida) › **✓**

**1.5** **+** de novo
- Código: `ALINH` · Descrição: `Alinhamento e balanceamento` · Tipo: **Serviço** · Unidade: **UN** · Conta: **Receita de Serviços** › **✓**

**1.6** *Cadastros › Veículos da frota*: confira o **ABC1D23 Caminhão Volvo FH 540**, que já vem no seed.

### Parte 2 — Aporte de capital (manual, porque é só dinheiro)

*Movimentos › Lançamento contábil*
- Histórico: `Aporte de capital dos sócios`
- Conta **Bancos** · **Débito** · `50000` › Adicionar → o rodapé fica vermelho; o valor `50000,00` já aparece sugerido com **Crédito** marcado.
- Conta **Capital Social** · Crédito · `50000` › Adicionar → o rodapé fica **verde** › **Gravar** → "Lançamento nº 1 gravado."

### Parte 3 — Compras (o sistema gera a contabilidade)

**3.1** *Movimentos › Compra*: fornecedor **Pneus Sul Ltda**, **À vista**
- **Pneu 175/70 R14** · Destino **Prateleira 1A** · `10` × `400` › Adicionar › **Gravar** → movimento nº 1, lançamento nº 2.
- **O sistema:** D Estoques 4.000 / C Bancos 4.000; custo médio do pneu = **400**.

**3.2** *Movimentos › Compra*: fornecedor **Distribuidora Rodas Ltda**, **A prazo**
- Pneu · Destino **Prateleira 2B** · `5` × `460` › Adicionar
- Filtro de óleo · Destino **Prateleira 3A** · `20` × `25` › Adicionar › **Gravar** → movimento nº 2, lançamento nº 3.
- **O sistema:** D Estoques 2.300 + D Estoques 500 / C **Fornecedores** 2.800. Novo custo médio do pneu: (10 × 400 + 5 × 460) ÷ 15 = **420**.

**3.3** *Movimentos › Compra*: fornecedor **Auto Peças Brasil SA**, **À vista**
- **Mão de obra mecânica** · `3` × `80`. Sem destino: serviço não tem estoque. › **Gravar** → lançamento nº 4: D Serviços de Terceiros 240 / C Bancos 240.

### Parte 4 — Transferência (sem contabilidade)

*Movimentos › Transferência entre locais*
- Pneu · Origem: a lista mostra **Prateleira 1A — 10** e **Prateleira 2B — 5**; escolha a **2B** · Destino **Prateleira 1A** · `3` › Adicionar › **Gravar**
- → "Transferência não gera lançamento contábil…". Saldos: 1A = 13 e 2B = 2.

### Parte 5 — Consumo (baixa pelo custo médio)

*Movimentos › Consumo*: conta **Despesa de Manutenção** · Observação `Material de oficina`
- Pneu · Origem **Prateleira 1A (13)** · `4` › Adicionar → a grade já mostra o valor estimado 4 × 420 = 1.680
- Filtro de óleo · Origem **Prateleira 3A (20)** · `2` › Adicionar › **Gravar** → lançamento nº 5: D Despesa de Manutenção 1.730 / C Estoques 1.680 / C Estoques 50.

### Parte 6 — Manutenção de veículo (peças + mão de obra, num lançamento só)

*Movimentos › Manutenção de veículo*
- Veículo: **ABC1D23 Caminhão Volvo FH 540** · Conta: **Despesa de Manutenção** (já vem escolhida)
- Fornecedor da mão de obra: **Auto Peças Brasil SA** · Pagamento: **A prazo**
- Pneu · Origem **Prateleira 1A (9)** · `2` › Adicionar (peça: valor pelo custo médio, 840)
- Filtro de óleo · Origem **Prateleira 3A (18)** · `1` › Adicionar (25)
- **Mão de obra mecânica** · `2` · Valor `90` › Adicionar. Para a mão de obra não há origem: ela não sai do estoque.
- **Gravar** → movimento nº 6, lançamento nº 6.
- **O sistema gerou um único lançamento:**

| | Conta | Valor |
|---|---|---:|
| D | Despesa de Manutenção | 1.045,00 |
| C | Estoques (pneus) | 840,00 |
| C | Estoques (filtro) | 25,00 |
| C | Fornecedores (mão de obra a prazo) | 180,00 |

- ✔ *Consultas › Custo de manutenção por veículo*: o Volvo aparece com 1 manutenção, peças 865, mão de obra 180, **total 1.045**. Clique na linha do Volvo e a grade de baixo mostra os 3 itens. A Van Sprinter aparece com zero.

**Teste de erro:** *Consumo* › Pneu: a origem mostra 1A (7) e 2B (2). Escolha a **2B** e peça `5` → "Saldo insuficiente… disponível 2, solicitado 5". **Nada é gravado.**

### Parte 7 — Prestação de serviço (receita)

**7.1** *Movimentos › Prestação de serviço*: cliente **Maria Souza**, **A prazo** · **Alinhamento e balanceamento** · `2` × `120` › Gravar → lançamento nº 7: D **Clientes** 240 / C Receita de Serviços 240.

**7.2** Cliente **Transportes Silva**, **À vista** · **Suporte técnico** · `3` × `150` › Gravar → lançamento nº 8: D Bancos 450 / C Receita de Serviços 450.

### Parte 8 — Movimentação financeira (manual)

Todos em *Movimentos › Lançamento contábil*:

| # | Histórico | Partidas |
|---|---|---|
| 9 | `Pagamento Distribuidora Rodas - NF 5521` | D **Fornecedores** 2.800 / C **Bancos** 2.800 |
| 10 | `Recebimento Maria Souza - alinhamento` | D **Bancos** 240 / C **Clientes** 240 |
| 11 | `Pagamento de salários do mês` | D **Despesa de Salários** 1.500 / C **Bancos** 1.500 |

A mão de obra da manutenção (180) ficou **em aberto** com a Auto Peças. É por isso que Fornecedores termina com saldo credor de 180.

### Parte 9 — Conferência final (os números têm que bater)

**Balancete:**

| Conta | Débitos | Créditos | Saldo devedor | Saldo credor |
|---|---:|---:|---:|---:|
| 1.1.1.02 Bancos | 50.690,00 | 8.540,00 | 42.150,00 | |
| 1.1.2.01 Clientes | 240,00 | 240,00 | 0,00 | 0,00 |
| 1.1.3.01 Estoques | 6.800,00 | 2.595,00 | 4.205,00 | |
| 2.1.1.01 Fornecedores | 2.800,00 | 2.980,00 | | 180,00 |
| 3.1.01 Capital Social | | 50.000,00 | | 50.000,00 |
| 4.1.02 Receita de Serviços | | 690,00 | | 690,00 |
| 5.2.01 Despesa de Salários | 1.500,00 | | 1.500,00 | |
| 5.2.02 Despesa de Manutenção | 2.775,00 | | 2.775,00 | |
| 5.2.03 Serviços de Terceiros | 240,00 | | 240,00 | |
| **Totais** | | | **50.870,00** | **50.870,00** ✓ |

Clique em **Imprimir (FastReport)** para ver o relatório.

**Resumo patrimonial:** Ativo **46.355,00** = Passivo **180,00** + PL **46.175,00**. O PL é o capital de 50.000 com o **prejuízo de 3.825**: receitas 690 − despesas 4.515.

**Saldo de estoque:** Filtro 3A = 17 (425,00) · Pneu 1A = 7 (2.940,00) · Pneu 2B = 2 (840,00) → **físico 4.205 = contábil 4.205 ✓**

**Razonete de Bancos:** débitos nº 1 (50.000), nº 8 (450) e nº 10 (240); créditos nº 2 (4.000), nº 4 (240), nº 9 (2.800) e nº 11 (1.500) → **saldo 42.150,00 D**.

**Diário** (*Consultas › Diário*, de 1º do mês até hoje): **11 lançamentos**, débitos 65.045,00 = créditos 65.045,00. A coluna Origem mostra **M** nos manuais (1, 9, 10 e 11) e **E** nos gerados pelo estoque. Para ver o filtro funcionando, mude o "De" e o "Até" para ontem: a lista fica vazia.

## 5. Usuários e permissões (o admin decide quem faz o quê)

**Exemplo pedido:** "quero que o usuário João possa registrar compras e ver o estoque".

1. *Sistema › Usuários e permissões* › aba **Perfis e permissões** › **+** › Nome do perfil: `Comprador` › **✓**
2. Na lista, marque **Registrar compras (MOV_COMPRA)** e **Consultar saldo de estoque e custo por veículo (EST_CONSULTAR)** › **Salvar permissões**
3. Aba **Usuários** › **+** › Login: `joao` · Nome: `João Comprador` · Perfil: **Comprador** · Ativo marcado · Nova senha: uma senha de teste à sua escolha (mínimo de 4 caracteres) › **✓**
4. *Sistema › Trocar usuário* › entre como `joao`:
   - **habilitados:** Compra, Saldo de estoque, Custo de manutenção por veículo;
   - **desabilitados:** Consumo, Transferência, Serviço, Manutenção, Lançamento contábil, Razonete, Balancete, Resumo, os cadastros e o menu de usuários.

Testes de segurança (como admin):

| Faça | Esperado |
|---|---|
| Desmarcar "Gerenciar usuários" do perfil Administrador e salvar | Bloqueado: você não pode tirar de si mesmo o acesso a esta tela |
| Excluir o próprio usuário, ou desmarcar o "Ativo" dele | Bloqueado |
| Excluir o perfil Comprador com o João dentro | "Há usuários neste perfil…" |
| Excluir um usuário que já fez lançamentos | Bloqueado pela chave estrangeira; a dica sugere inativar |
| Editar o João (▲) com a senha em branco e salvar | A senha antiga continua valendo |

As permissões são lidas no login: depois de mudar um perfil, use **Trocar usuário** para valer.

## 6. Mais testes de erro (para mostrar as regras)

| Onde | Faça | Esperado |
|---|---|---|
| Clientes e fornecedores | Clicar em **+** e depois na grade | A grade está bloqueada: o registro novo não se perde |
| Clientes e fornecedores | Excluir **Pneus Sul Ltda** (tem compras) | "Este registro é usado em outro cadastro ou movimento…" |
| Veículos | Placa `AB-12` | "A placa deve ter 7 caracteres…" |
| Plano de contas | Editar **Bancos** e marcar como Sintética | "Esta conta tem lançamentos: não pode virar sintética." |
| Locais | Marcar "Aceita estoque" no **Almoxarifado Central** | "Este local tem sub-locais…" |
| Manutenção | Gravar sem escolher o veículo | "Escolha o veículo que recebeu a manutenção." |
| Manutenção | Mão de obra sem fornecedor | "A manutenção tem mão de obra: escolha o fornecedor…" |
| Diário | "De" maior que "Até" | "A data inicial é maior que a final." |

## 7. Atalhos para a demonstração

- *Sistema › Demonstração › Carregar cenário Pet Shop da Bia*: balancete 25.000 = 25.000.
- *Sistema › Demonstração › Carregar cenário da frota (pneus)*: custo médio 520; conciliação 2.600 = 2.600.
- Use **Zerar movimentos** antes de cada cenário, para os números baterem com os valores acima.
