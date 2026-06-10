#!/bin/bash
set -e

# Configuration
PROJECT_NAME="learnmarket"
REGION="eu-west-3"  # Paris pour Tunisie/Europe
RANDOM_SUFFIX=$(date +%s)
BUCKET_NAME="${PROJECT_NAME}-terraform-state-${RANDOM_SUFFIX}"
TABLE_NAME="${PROJECT_NAME}-terraform-locks"

echo "Bootstrap du state Terraform pour ${PROJECT_NAME}"
echo "Region: ${REGION}"
echo "Bucket: ${BUCKET_NAME}"
echo "Table: ${TABLE_NAME}"
echo ""

# Vérifier que AWS CLI fonctionne
echo "Vérification AWS CLI..."
aws sts get-caller-identity --output table
echo ""

# Confirmer
read -p "Continuer ? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Annulé"
    exit 1
fi

# Créer le bucket S3
echo "Création du bucket S3..."
aws s3api create-bucket \
    --bucket "${BUCKET_NAME}" \
    --region "${REGION}" \
    --create-bucket-configuration LocationConstraint="${REGION}"

# Activer le versioning (important pour pouvoir revenir en arrière sur le state)
echo "Activation du versioning..."
aws s3api put-bucket-versioning \
    --bucket "${BUCKET_NAME}" \
    --versioning-configuration Status=Enabled

# Activer l'encryption par défaut
echo "Activation de l'encryption..."
aws s3api put-bucket-encryption \
    --bucket "${BUCKET_NAME}" \
    --server-side-encryption-configuration '{
        "Rules": [{
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "AES256"
            }
        }]
    }'

# Bloquer l'accès public (important pour la sécurité)
echo "Blocage de l'accès public..."
aws s3api put-public-access-block \
    --bucket "${BUCKET_NAME}" \
    --public-access-block-configuration \
        "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# Créer la table DynamoDB pour le lock
echo "Création de la table DynamoDB pour le lock..."
aws dynamodb create-table \
    --table-name "${TABLE_NAME}" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "${REGION}" \
    --tags Key=Project,Value="${PROJECT_NAME}" Key=ManagedBy,Value=manual-bootstrap

# Attendre que la table soit créée
echo "Attente de la création de la table..."
aws dynamodb wait table-exists --table-name "${TABLE_NAME}" --region "${REGION}"

echo ""
echo "Bootstrap terminé avec succès !"
echo ""
echo "Ajoute cette configuration dans tes fichiers backend.tf :"
echo ""
echo "terraform {"
echo "  backend \"s3\" {"
echo "    bucket         = \"${BUCKET_NAME}\""
echo "    key            = \"ENVIRONMENT/terraform.tfstate\""
echo "    region         = \"${REGION}\""
echo "    encrypt        = true"
echo "    dynamodb_table = \"${TABLE_NAME}\""
echo "  }"
echo "}"
echo ""
echo "Sauvegarde ces infos dans un fichier sécurisé !"

# Sauvegarder dans un fichier
cat > .bootstrap-output.txt <<EOF
# Terraform Backend Configuration
# Generated: $(date)

BUCKET_NAME=${BUCKET_NAME}
TABLE_NAME=${TABLE_NAME}
REGION=${REGION}

# Use in backend.tf:
terraform {
  backend "s3" {
    bucket         = "${BUCKET_NAME}"
    key            = "ENVIRONMENT/terraform.tfstate"
    region         = "${REGION}"
    encrypt        = true
    dynamodb_table = "${TABLE_NAME}"
  }
}
EOF

echo "Configuration sauvegardée dans .bootstrap-output.txt"