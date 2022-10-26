build:
	-dfx stop && rm -rf .dfx/
	dfx start --clean --background
	dfx deploy