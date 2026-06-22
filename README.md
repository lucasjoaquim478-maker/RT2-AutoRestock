# Retail Tycoon 2 - Auto Restock Bot

Bot para **Retail Tycoon 2** que gerencia sua loja automaticamente: detecta produtos acabando e faz reabastecimento.

## Como usar

1. Abra o Roblox e entre no **Retail Tycoon 2**
2. Abra seu executor (Madium)
3. Copie o conteúdo de `scripts/main.lua`
4. Cole e execute
5. Configure os produtos e quantidades mínimas na UI que aparecer

## Funcionalidades

- **Scan automático** — detecta todos os produtos nas prateleiras
- **Auto Restock** — reabastece quando estoque fica abaixo do mínimo
- **UI configurável** — ajusta quantidade mínima por produto
- **Whitelist/Blacklist** — ativa/desativa restock por produto
- **Logs** — mostra o que está sendo reabastecido

## Estrutura

```
scripts/
  main.lua    Script principal (copiar e colar no executor)
```

## Ajustes

Se o script não detectar os produtos ou o restock não funcionar, pode ser necessário ajustar:

1. O nome dos objetos das prateleiras no jogo
2. O RemoteEvent usado para comprar/reabastecer
3. O caminho dos dados do jogador

Abra o `main.lua` e procure por `-- AJUSTE:` para ver os pontos que podem precisar de adaptação.
