# concessionaria-tde
# Concessionária – Banco de Dados

Projeto de modelagem e implementação de um banco de dados relacional para uma concessionária de veículos que vende carros novos e usados e também oferece serviços de reparo e manutenção. Foi desenvolvido como atividade prática de Modelagem de Banco de Dados (Senac).

O banco cobre seis contextos do negócio:

- **Vendas de veículos:** cada carro é vendido por um único vendedor a um único cliente.
- **Faturamento:** cada venda gera uma única fatura.
- **Clientes:** podem ter comprado veículos ou usar apenas a oficina.
- **Ordens de serviço:** uma ordem específica para cada veículo atendido, da abertura à conclusão.
- **Histórico de manutenção:** registro dos serviços de cada veículo, identificado pelo número de série.
- **Mecânicos e peças:** uma ordem pode ter vários mecânicos e usar uma ou mais peças, ou nenhuma.

## Tecnologias utilizadas

| Tecnologia | Uso |
|---|---|
| PostgreSQL 16 | Sistema gerenciador de banco de dados (o script foi testado nesta versão) |
| SQL (DDL e DML) | Criação das tabelas, restrições e carga de dados de exemplo |
| DBeaver | Cliente para executar o script e consultar os dados |
| Mermaid | Diagramas do modelo entidade-relacionamento e dos fluxos, neste README |
| Git e GitHub | Versionamento e publicação do projeto |

## Estrutura do repositório

```
.
├── README.md
├── concessionaria.sql            # DROP, CREATE TABLE e INSERTs de cada tabela
└── concessionaria_tabelas.docx   # Análise de requisitos, relacionamentos e modelo lógico
```

## Como executar

1. Crie um banco de dados vazio no PostgreSQL (por exemplo, `concessionaria`).
2. Abra o arquivo `concessionaria.sql` no DBeaver, conectado a esse banco.
3. Execute o script inteiro com **Alt+X** (Execute Script). Com Ctrl+Enter o DBeaver executa só um comando.

Pelo terminal, o equivalente é:

```bash
psql -d concessionaria -f concessionaria.sql
```

O script começa com os `DROP TABLE IF EXISTS` na ordem inversa das dependências, então pode ser executado várias vezes.

## Modelo entidade-relacionamento

```mermaid
erDiagram
    cli_cliente ||--o{ vnd_venda : compra
    ven_vendedor ||--o{ vnd_venda : realiza
    vei_veiculo |o--|| vnd_venda : "é vendido em"
    vnd_venda ||--|| fat_fatura : gera
    cli_cliente ||--o{ ord_ordem_servico : solicita
    vei_veiculo ||--o{ ord_ordem_servico : "é atendido em"
    ord_ordem_servico ||--|{ orm_ordem_mecanico : "é executada por"
    mec_mecanico ||--o{ orm_ordem_mecanico : atua
    ord_ordem_servico ||--o{ ops_ordem_peca : utiliza
    pec_peca ||--o{ ops_ordem_peca : "é usada em"
    vei_veiculo ||--o{ his_historico_manutencao : possui
    ord_ordem_servico |o--|| his_historico_manutencao : registra

    cli_cliente {
        serial cli_id PK
        varchar cli_nome
        char cli_cpf UK
        varchar cli_fone
        varchar cli_email UK "opcional"
        varchar cli_endereco "opcional"
        date cli_dtcadastro
    }
    ven_vendedor {
        smallserial ven_id PK
        varchar ven_nome
        char ven_cpf UK
        varchar ven_fone
        varchar ven_email UK
        date ven_dtadmissao
        decimal ven_comissao
    }
    mec_mecanico {
        smallserial mec_id PK
        varchar mec_nome
        char mec_cpf UK
        varchar mec_fone
        varchar mec_email UK "opcional"
        varchar mec_especialidade
        date mec_dtadmissao
    }
    vei_veiculo {
        char vei_numserie PK
        varchar vei_marca
        varchar vei_modelo
        smallint vei_anofabricacao
        varchar vei_cor "opcional"
        char vei_placa UK "opcional"
        varchar vei_condicao
        int vei_km
        decimal vei_preco "opcional"
    }
    vnd_venda {
        serial vnd_id PK
        char vnd_vei_numserie FK, UK
        smallint vnd_ven_id FK
        int vnd_cli_id FK
        date vnd_data
        decimal vnd_valor
    }
    fat_fatura {
        serial fat_id PK
        int fat_vnd_id FK, UK
        varchar fat_numero UK
        date fat_dtemissao
        decimal fat_valortotal
        varchar fat_formapagto
        varchar fat_situacao
    }
    ord_ordem_servico {
        serial ord_id PK
        int ord_cli_id FK
        char ord_vei_numserie FK
        date ord_dtabertura
        date ord_dtconclusao "opcional"
        varchar ord_tipo
        varchar ord_situacao
        varchar ord_descricao
        decimal ord_valormaodeobra
    }
    pec_peca {
        smallserial pec_id PK
        varchar pec_codigo UK
        varchar pec_nome
        varchar pec_fabricante "opcional"
        decimal pec_preco
        int pec_estoque
    }
    orm_ordem_mecanico {
        int orm_ord_id PK, FK
        smallint orm_mec_id PK, FK
        decimal orm_horas "opcional"
        varchar orm_funcao "opcional"
    }
    ops_ordem_peca {
        int ops_ord_id PK, FK
        smallint ops_pec_id PK, FK
        smallint ops_quantidade
        decimal ops_precounit
    }
    his_historico_manutencao {
        char his_vei_numserie PK, FK
        smallint his_seq PK
        int his_ord_id FK, UK
        date his_data
        int his_km
        varchar his_tiposervico
        varchar his_descricao
    }
```

## Fluxos do negócio

### Venda e faturamento

```mermaid
flowchart TD
    A([Cliente escolhe um veículo]) --> B{"Cliente já cadastrado?"}
    B -- Não --> C["Cadastrar em cli_cliente"]
    B -- Sim --> D
    C --> D["Vendedor registra a venda em vnd_venda"]
    D --> E["Sistema emite 1 fatura em fat_fatura"]
    E --> F{"Situação da fatura"}
    F -- Pendente --> G["Aguardando pagamento"]
    F -- Paga --> H([Venda concluída])
    F -- Cancelada --> I([Fatura cancelada])
    G --> F
```

### Ordem de serviço e histórico de manutenção

```mermaid
flowchart TD
    A([Cliente leva o veículo à oficina]) --> B{"Cliente cadastrado?"}
    B -- Não --> C["Cadastrar em cli_cliente"]
    B -- Sim --> D
    C --> D{"Veículo cadastrado?"}
    D -- Não --> E["Cadastrar em vei_veiculo"]
    D -- Sim --> F
    E --> F["Abrir ordem em ord_ordem_servico: situação Aberta"]
    F --> G["Atribuir 1 ou mais mecânicos em orm_ordem_mecanico"]
    G --> H["Situação Em Andamento"]
    H --> I{"Serviço usa peças?"}
    I -- Sim --> J["Registrar peças em ops_ordem_peca"]
    I -- Não --> K
    J --> K["Executar o serviço"]
    K --> L["Situação Concluída e preencher ord_dtconclusao"]
    L --> M["Registrar em his_historico_manutencao: série do veículo + seq"]
    M --> N([Veículo entregue ao cliente])
```

## Principais regras de negócio

- Um veículo só pode ser vendido uma vez (`UNIQUE` em `vnd_vei_numserie`).
- Cada venda tem exatamente um vendedor, um cliente e uma fatura (`fat_vnd_id` é único).
- Um cliente pode existir sem nunca ter comprado um veículo.
- Cada ordem de serviço é de um único veículo e um único cliente.
- Uma ordem pode ter vários mecânicos, e um mecânico pode atuar em várias ordens.
- Uma ordem pode usar várias peças ou nenhuma.
- Uma ordem "Concluída" exige data de conclusão, que não pode ser anterior à abertura.
- O histórico de manutenção é identificado pelo número de série do veículo mais uma sequência, e cada registro vem de uma única ordem do mesmo veículo.
- A regra "toda ordem tem ao menos um mecânico" não é imposta por constraint em SQL. Ela exigiria trigger ou validação na aplicação.

## Consultas de exemplo

```sql
SELECT v.vnd_id, c.cli_nome AS cliente, ve.ven_nome AS vendedor,
       vei.vei_modelo, v.vnd_valor, f.fat_numero, f.fat_situacao
FROM vnd_venda v
JOIN cli_cliente  c   ON c.cli_id = v.vnd_cli_id
JOIN ven_vendedor ve  ON ve.ven_id = v.vnd_ven_id
JOIN vei_veiculo  vei ON vei.vei_numserie = v.vnd_vei_numserie
JOIN fat_fatura   f   ON f.fat_vnd_id = v.vnd_id;

SELECT h.his_vei_numserie, h.his_seq, h.his_data, h.his_km,
       h.his_tiposervico, h.his_descricao
FROM his_historico_manutencao h
WHERE h.his_vei_numserie = '9BWZZZ377VT004251'
ORDER BY h.his_seq;
```