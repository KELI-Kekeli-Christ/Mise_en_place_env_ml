#!/bin/bash

clear
echo "✨==========================================✨"
echo "     🚀 Installation complète ML + GitHub"
echo "✨==========================================✨"
sleep 1

# -----------------------------------------
# 🧩 Étape 1 : Mises à jour et dépendances
# -----------------------------------------
echo "🔧 Mise à jour du système..."
sudo apt update -y >/dev/null
sudo apt install -y python3 python3-pip git curl -qq
echo "✅ Système prêt !"
sudo apt install python3-venv
# -----------------------------------------
# ⚙️ Étape 2 : Configuration Git globale
# -----------------------------------------
echo ""
echo "🧑‍💻 Configuration Git"
read -p "Entrez votre nom d'utilisateur GitHub : " GIT_USERNAME
read -p "Entrez votre email GitHub : " GIT_EMAIL

git config --global user.name "$GIT_USERNAME"
git config --global user.email "$GIT_EMAIL"

echo "✅ Git configuré avec succès !"
git config --list | grep "user"

# -----------------------------------------
# 🧠 Étape 3 : Environnement virtuel
# -----------------------------------------
echo ""
read -p "Entrez le nom de l'environnement virtuel Python : " ENVNAME
python3 -m venv "$ENVNAME"

OS="$(uname)"
if [[ "$OS" == "Linux" || "$OS" == "Darwin" ]]; then
    ACTIVATE_CMD="source $ENVNAME/bin/activate"
elif [[ "$OS" =~ "MINGW" || "$OS" =~ "MSYS" || "$OS" =~ "CYGWIN" ]]; then
    ACTIVATE_CMD="$ENVNAME\\Scripts\\activate"
else
    echo "⚠️ Système non reconnu. Activez manuellement votre environnement."
fi

echo ""
echo "💡 Pour activer plus tard, exécutez :"
echo "   $ACTIVATE_CMD"
eval "$ACTIVATE_CMD"
sleep 1

echo "🚀 Mise à jour de pip et installation des librairies ML..."
pip install --upgrade pip >/dev/null
pip install numpy pandas matplotlib seaborn scikit-learn jupyter >/dev/null
echo "✅ Librairies basiques installées !"

# -----------------------------------------
# 🔐 Étape 4 : Gestion de la clé SSH
# -----------------------------------------
SSH_KEY=""
for k in id_ed25519 id_rsa id_ecdsa; do
    if [ -f "$HOME/.ssh/$k.pub" ]; then
        SSH_KEY="$HOME/.ssh/$k.pub"
        echo "🔑 Clé SSH détectée : $SSH_KEY"
        break
    fi
done

if [ -z "$SSH_KEY" ]; then
    echo "⚙️ Aucune clé SSH trouvée, création d’une nouvelle clé..."
    ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$HOME/.ssh/id_ed25519" -N "" >/dev/null
    SSH_KEY="$HOME/.ssh/id_ed25519.pub"
    echo "✅ Nouvelle clé SSH générée : $SSH_KEY"
fi

# -----------------------------------------
# 🧰 Étape 5 : Installation GitHub CLI
# -----------------------------------------
if ! command -v gh &> /dev/null; then
    echo "📦 Installation de GitHub CLI..."
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg >/dev/null
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
    sudo apt update -qq && sudo apt install gh -y >/dev/null
    echo "✅ GitHub CLI installé !"
fi

# -----------------------------------------
# 🔗 Étape 6 : Authentification & clé SSH
# -----------------------------------------
if ! gh auth status &>/dev/null; then
    echo "🔐 Authentification GitHub requise..."
    gh auth login
else
    echo "✅ Déjà connecté à GitHub !"
fi

if ! gh ssh-key list | grep -q "$(cat $SSH_KEY)"; then
    gh ssh-key add "$SSH_KEY" --title "Clé auto ML Setup $(date +"%Y-%m-%d_%H-%M")"
    echo "✅ Clé SSH ajoutée à ton compte GitHub !"
else
    echo "🔁 Clé SSH déjà enregistrée sur GitHub."
fi

# -----------------------------------------
# 📦 Étape 7 : Création du dépôt GitHub
# -----------------------------------------
read -p "Entrez le nom du dépôt GitHub à créer : " REPONAME
gh repo create "$REPONAME" --public --confirm >/dev/null

git init >/dev/null
git remote add origin "git@github.com:$GIT_USERNAME/$REPONAME.git"
echo "# $REPONAME" > README.md
git add README.md
git commit -m "Initial commit" >/dev/null
git branch -M main
git push -u origin main >/dev/null

REPO_URL="https://github.com/$GIT_USERNAME/$REPONAME"
echo "🌐 Dépôt créé : $REPO_URL"

# -----------------------------------------
# 💻 Étape 8 : Détection du GPU NVIDIA
# -----------------------------------------
echo ""
echo "🧠 Vérification du GPU..."
if command -v nvidia-smi &> /dev/null; then
    GPU_INFO=$(nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv,noheader)
    echo "🔥 GPU NVIDIA détecté : $GPU_INFO"
else
    echo "⚠️ Aucun GPU NVIDIA détecté (ou pilotes non installés)."
fi

# -----------------------------------------
# 🎉 Étape finale : Résumé
# -----------------------------------------
echo ""
echo "✨==========================================✨"
echo "🎉 Installation terminée avec succès ! 🎉"
echo "🧠 Environnement ML : $ENVNAME"
echo "🔑 Clé SSH : $SSH_KEY"
echo "🌐 Dépôt GitHub : $REPO_URL"
echo "🚀 Pour activer ton environnement : $ACTIVATE_CMD"
echo "✨==========================================✨"
echo ""
echo "💫 Bon code, champion du Machine Learning 💪🤖"
