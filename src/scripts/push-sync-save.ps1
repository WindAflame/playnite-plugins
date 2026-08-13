# If user can't pull from romm, exit with error code 1
# Auto-detect steam install
# If steam is not found, exit with error code 1
# Auto-detect retroarch install in steam library
# If retroarch is not found, exit with error code 1
# Fetch save files from retroarch save folder
# If no save files are found, exit with error code 1
# Fetch save files from romm
# If no save files are found, push save files to romm
# Else, compare save files from romm and retroarch save folder and push the latest one