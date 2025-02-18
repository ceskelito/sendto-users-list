#!/bin/bash

# Chat GPT docet

# Configura i dettagli
USERNAME=$(whoami | awk '{print "\n"$1}')
REPO_OWNER="ceskelito"
REPO_NAME="sendto-userslist"
FILE_PATH="userslist"
TOKEN_PART_1="github_pat_11BJYWBNQ07CXecbeKsrCv_"  
TOKEN_PART_2="OK4NKks8vrU7yoIc4ewWTGrv8eVineAZIURo13pFpbK5GSYRHAAkUihgcxw"

# URL per GitHub API
URL="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/contents/$FILE_PATH"

# Ottieni il contenuto del file esistente dal repository
response=$(curl -s -H "Authorization: token $TOKEN_PART_1$TOKEN_PART_2" $URL)
sha=$(echo $response | jq -r '.sha')
content_base64=$(echo $response | jq -r '.content')

# Decodifica il contenuto base64 del file
content=$(echo $content_base64 | base64 --decode)

# Aggiungi il nome utente come nuova riga
new_content="$content$USERNAME"

# Codifica nuovamente il contenuto in base64
new_content_base64=$(echo -n "$new_content" | base64)

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
curl -X PUT -H "Authorization: token $TOKEN" -d "$data" $URL

#echo "File aggiornato con successo!"
