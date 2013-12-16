PPTGallery_vagrant
==================

This is Vagrantfile and provisioning cookbooks for [kaakaa/PPTGallery](https://github.com/kaakaa/PPTGallery "kaakaa/PPTGallery").

USAGE
-----

This depends on [opscode-cookbooks/iptables](https://github.com/opscode-cookbooks/iptables "opscode-cookbooks/iptables").

So after cloning this, you must exec cloning git submodule.

```
git submodule init
git submodule update
```

And then add iptables setting in iptables cookbooks.

```
touch cookbooks/iptables/templates/default/http.rb
echo "-A FWR -m tcp -p tcp --dport 5000 -j ACCEPT" >> cookbooks/iptables/templates/default/http.rb
echo "-A FWR -m tcp -p tcp --sport 5000 -j ACCEPT" >> cookbooks/iptables/templates/default/http.rb

echo "iptables_rule 'http'" >> cookbooks/iptables/recipes/default.rb 
```

Lastly vagrant up.
```
vagrant up
```
