# server 'administrator@192.76.129.30', :app
# server 'administrator@192.76.129.25', :app
server 'administrator@192.76.129.26', :app, runner: 'talk1'
role :slave, 'talk0@192.76.129.26', no_release: true
role :slave, 'talk1@192.76.129.26', no_release: true
role :slave, 'talk2@192.76.129.26', no_release: true
role :slave, 'talk3@192.76.129.26', no_release: true
role :slave, 'talk4@192.76.129.26', no_release: true
role :slave, 'talk5@192.76.129.26', no_release: true
role :slave, 'talk6@192.76.129.26', no_release: true
role :slave, 'talk7@192.76.129.26', no_release: true
role :slave, 'talk8@192.76.129.26', no_release: true
role :slave, 'talk9@192.76.129.26', no_release: true
