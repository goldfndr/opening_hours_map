OpenLayersVersion := 2.13.1

## help {{{
.PHONY: list
# https://stackoverflow.com/a/26339924/2239985
list:
	@echo "This Makefile has the following targets:"
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | sed 's/^/    /'
## }}}

## Make this project ready to be served by a webserver.
.PHONY: ready-for-hosting
ready-for-hosting: dependencies-get
	$(MAKE) --directory opening_hours.js/ ready-for-hosting

taginfo.json: ./opening_hours.js/gen_taginfo_json.js ./opening_hours.js/related_tags.txt taginfo_template.json
	$< --key-file ./opening_hours.js/related_tags.txt --template-file taginfo_template.json > "$@"

.PHONY: dependencies-get
dependencies-get: js/OpenLayers-$(OpenLayersVersion)/OpenLayers.js
	git submodule update --init --recursive

js/OpenLayers-$(OpenLayersVersion)/OpenLayers.js:
	-wget --no-clobber -O js/OpenLayers-$(OpenLayersVersion).tar.gz https://github.com/openlayers/openlayers/releases/download/release-$(OpenLayersVersion)/OpenLayers-$(OpenLayersVersion).tar.gz
	tar -xzf js/OpenLayers-$(OpenLayersVersion).tar.gz -C js/

.PHONY: publish-website-on-all-servers
publish-website-on-all-servers: publish-website-on-openingh.openstreetmap.de publish-website-on-ypid.de

.PHONY: publish-website-on-openingh.openstreetmap.de
publish-website-on-openingh.openstreetmap.de:
	rsync  --archive * gauss.osm.de:~/www -v

.PHONY: publish-website-on-openingh.openstreetmap.de
publish-website-on-ypid.de:
	rsync  --archive * osm_admin@js-1und1-vps:/srv/www/osm/userdir/public -v
