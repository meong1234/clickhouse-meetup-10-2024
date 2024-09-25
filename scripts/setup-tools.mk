# Tools setup

brew-common:
	brew update
	brew list kubectl || brew install kubectl
	brew list kustomize || brew install kustomize
	brew list k9s || brew install k9s
	brew list fluxcd/tap/flux || brew install fluxcd/tap/flux

python-common:
	pip install kafka-python