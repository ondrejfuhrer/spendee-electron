## Get the current version of the app
version=$(npm run --silent version)

## Stash all current changes so that they are not pushed to the release
git add .
git stash -m "Pre-release stash ${version}"

## Calculate new release version
release_version=${version/"-dev"/}

## Replace the version in package.json so that the release is created correctly
sed -i .old "s/"${version}"/${release_version}/" package.json
npm install

## Create release commit
git add package.json package-lock.json
git commit -m "[Release] Bump version to ${version}"
git push

## Create artifacts
npm run make

## Create release
gh release create "${release_version}" -d -t "${release_version}" "./out/make/Spendee-${release_version}.dmg" "./out/make/zip/darwin/x64/Spendee-darwin-x64-${release_version}.zip"

## Update release notes
npm run release-notes -- --override

## Update Changelog
npm run changelog

## Cleanup temporary files
rm -f package.json.old
# rm -f package.json
# mv package.json.old package.json

## Setup -dev version as next in line
./scripts/steps/increase_version.sh "${release_version}"

## Get the current version of the app
version=$(npm run --silent version)

## Increase
git add package.json package-lock.json CHANGELOG.md
git commit -m "Bump version to ${version}"

## Add back shashed changers
git stash pop

echo "Version ${release_version} has been released and new version ${version} set."
