# Nom de l'image Docker
IMAGE_NAME = flutter-env

# Port utilisé pour Flutter Web
PORT = 8080

# Construction de l'image Docker
build:
	docker build -t $(IMAGE_NAME) .

# Lancer un container interactif sans volume
run:
	docker run -it --rm -p $(PORT):$(PORT) $(IMAGE_NAME)

# Lancer un container avec montage du dossier actuel (développement)
run-dev:
	docker run -it --rm \
		-v $(PWD):/home/flutteruser/app \
		-p $(PORT):$(PORT) \
		$(IMAGE_NAME)

# Supprimer l'image Docker
clean:
	docker rmi $(IMAGE_NAME)

# Créer un projet Flutter dans le container
create-app:
	docker run -it --rm $(IMAGE_NAME) flutter create myapp

# Crée et lance une app Flutter web immédiatement
serve:
	docker run -it --rm -p $(PORT):$(PORT) $(IMAGE_NAME) \
		bash -c "flutter create myapp && cd myapp && flutter run -d web-server --web-port=$(PORT) --web-hostname=0.0.0.0"

# Afficher les commandes disponibles
help:
	@echo "Commandes disponibles :"
	@echo "  make build        -> Build l'image Docker"
	@echo "  make run          -> Lance le container Flutter (sans volume)"
	@echo "  make run-dev      -> Lance le container avec montage du dossier actuel"
	@echo "  make create-app   -> Crée un projet Flutter dans /app"
	@echo "  make serve        -> Crée et lance une app Flutter Web dans un container"
	@echo "  make clean        -> Supprime l'image Docker"
