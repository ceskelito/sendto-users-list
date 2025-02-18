#!/bin/bash

# Chat GPT docet

# Configura i dettagli
USERNAME=$(whoami) # Rimosso awk per evitare newline extra
REPO_OWNER="ceskelito"
REPO_NAME="sendto-userslist"
FILE_PATH="userslist"
TOKEN_PART_1="github_pat_11BJYWBNQ07CXecbeKsrCv_"
TOKEN_PART_2="OK4NKks8vrU7yoIc4ewWTGrv8eVineAZIURo13pFpbK5GSYRHAAkUihgcxw"
TOKEN="${TOKEN_PART_1}${TOKEN_PART_2}"

# URL per GitHub API
URL="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/contents/$FILE_PATH"

# Ottieni il contenuto del file esistente dal repository
response=$(curl -s -H "Authorization: token $TOKEN" $URL)
sha=$(echo "$response" | jq -r '.sha')
content_base64=$(echo "$response" | jq -r '.content')

# Controlla se il file esiste e il contenuto è valido
if [[ -z "$sha" || -z "$content_base64" ; "$content_base64" == "null" ]]; then
  echo "Errore: Il file non esiste o non è accessibile."
  exit 1
fi

# Decodifica il contenuto base64 del file (rimuove newline extra)
content=$(echo "$content_base64" | tr -d '\n' | base64 --decode)

# Aggiungi il nome utente come nuova riga
new_content="${content}||${USERNAME}"

# Codifica nuovamente il contenuto in base64
new_content_base64=$(echo -n "$new_content" | base64 | tr -d '\n')

# Prepara i dati per l'aggiornamento
data=$(cat <<EOF
{
  "message": "Aggiungi nome utente",
  "content": "$new_content_base64",
  "sha": "$sha"
}
EOF
)

# Esegui l'aggiornamento tramite la GitHub API
update_response=$(curl -s -X PUT -H "Authorization: token $TOKEN" -d "$data" $URL)

# Controlla se l'aggiornamento è riuscito
if echo "$update_response" | grep -q '"content"'; then
  echo "File aggiornato con successo!"
else
  echo "Errore durante l'aggiornamento: $(echo "$update_response" | jq -r '.message')"
fi
