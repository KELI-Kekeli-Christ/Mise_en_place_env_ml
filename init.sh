#!/bin/bash

# ==========================================================
# 🚀 Script complet d’installation d’un environnement ML + GitHub
# Auteur : Christ ✨ | Version : 1.0
# ==========================================================

clear
echo "🌍 Initialisation de l'environnement Machine Learning..."
sleep 1
echo "---------------------------------------------------------"

# 🧠 Mise à jour du système
sudo apt update -y && sudo apt upgrade -y
echo "✅ Système mis à jour !"

# 🐍 Installation Python, pip et git
sudo apt install -y python3 python3-pip git curl
echo "✅ Python3, pip et git installés !"

# 💻 Vérification GPU NVIDIA
echo "🔍 Vérification de la présence d’un GPU NVIDIA..."
if command -v nvidia-smi &> /dev/null; then
    GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader)
    echo "💪 GPU détecté : $GPU_NAME"
else
    echo "⚠️ Aucun GPU NVIDIA détecté. Installation CPU standard."
fi
sleep 1

# 🌱 Création de l’environnement virtuel
read -p "🧩 Entrez le nom de l'environnement virtuel : " ENVNAME
python3 -m venv "$ENVNAME"

OS="$(uname)"
if [[ "$OS" == "Linux" || "$OS" == "Darwin" ]]; then
    ACTIVATE_CMD="source $ENVNAME/bin/activate"
    eval "$ACTIVATE_CMD"
elif [[ "$OS" =~ "MINGW" || "$OS" =~ "MSYS" || "$OS" =~ "CYGWIN" ]]; then
    ACTIVATE_CMD="$ENVNAME\\Scripts\\activate"
else
    echo "🤷 Système inconnu, activation manuelle requise."
fi

echo "✅ Environnement virtuel activé !"
sleep 1

# 📦 Installation des librairies de base ML
echo "📦 Installation des packages ML..."
pip install --upgrade pip
pip install numpy pandas matplotlib seaborn scikit-learn jupyter notebook tqdm rich

# ⚙️ Installation des librairies IA avancées
echo "🤖 Installation des librairies IA avancées..."
if command -v nvidia-smi &> /dev/null; then
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
    echo "🔥 PyTorch avec CUDA installé !"
else
    pip install torch torchvision torchaudio
    echo "🧠 PyTorch CPU-only installé."
fi

pip install tensorflow keras xgboost lightgbm
pip install opencv-python pillow scikit-image

# 💾 Vérification ou création clé SSH
echo "🔐 Vérification de la clé SSH..."
SSH_KEY=""
for k in id_ed25519 id_rsa id_ecdsa; do
    if [ -f "$HOME/.ssh/$k.pub" ]; then
        SSH_KEY="$HOME/.ssh/$k.pub"
        echo "✅ Clé SSH détectée : $SSH_KEY"
        break
    fi
done

if [ -z "$SSH_KEY" ]; then
    read -p "✉️  Entrez votre email GitHub pour créer une nouvelle clé : " USER_EMAIL
    ssh-keygen -t ed25519 -C "$USER_EMAIL" -f "$HOME/.ssh/id_ed25519" -N ""
    SSH_KEY="$HOME/.ssh/id_ed25519.pub"
    echo "✨ Nouvelle clé SSH générée : $SSH_KEY"
fi

# 🧰 Installation GitHub CLI (gh)
if ! command -v gh &> /dev/null; then
    echo "⬇️ Installation de GitHub CLI..."
    type -p curl >/dev/null || sudo apt install curl -y
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update && sudo apt install gh -y
fi

# 🔑 Authentification GitHub + ajout clé SSH
gh auth status 2>&1 | grep 'You are not logged' && gh auth login
gh ssh-key list | grep "$(cat $SSH_KEY)" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    gh ssh-key add "$SSH_KEY" --title "Clé auto $(date +"%Y-%m-%d_%H-%M")"
else
    echo "🔁 Clé SSH déjà présente sur GitHub."
fi

# 🧱 Création du dépôt GitHub
read -p "📘 Entrez le nom du dépôt GitHub à créer : " REPONAME
USERNAME=$(gh api user | grep login | awk -F\" '{print $4}')
gh repo create "$REPONAME" --public --confirm
git init
git remote add origin "git@github.com:$USERNAME/$REPONAME.git"
echo "# $REPONAME" > README.md
git add README.md
git commit -m "🚀 Initial commit"
git branch -M main
git push -u origin main

REPO_URL="https://github.com/$USERNAME/$REPONAME"

# 🎉 Résumé final
echo ""
echo "=========================================================="
echo "✨ INSTALLATION TERMINÉE AVEC SUCCÈS ! ✨"
echo "🐍 Environnement virtuel : $ENVNAME"
echo "📂 Dépôt GitHub : $REPONAME"
echo "🔗 Lien du dépôt : $REPO_URL"
if [ -n "$GPU_NAME" ]; then
    echo "💻 GPU détecté : $GPU_NAME"
else
    echo "⚙️  Aucun GPU détecté."
fi
echo "=========================================================="
echo "🌟 Merci d'utiliser le setup ML de Christ ❤️"
echo "🚀 Bon code et que les modèles soient avec toi ! 🤖✨"
