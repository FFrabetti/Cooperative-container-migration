# Machine configuration #

## Hostnames and network interfaces ##
```
su root
nano /etc/network/interfaces
nano /etc/hostname 
nano /etc/hosts
exit
```

## SSH ##
From node A, to ssh into node B without password:

```
A$ 	cat .ssh/id_rsa.pub | ssh B 'cat >> .ssh/authorized_keys'
```
