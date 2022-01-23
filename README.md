# ZSH AWS Vault

A zsh plugin for aws-vault which includes completions and cli functions.

## Installation

### [Antigen](https://github.com/zsh-users/antigen)

```
antigen bundle dannysteenman/zsh-aws-vault
```

### [Antibody](https://getantibody.github.io)

```
antibody bundle dannysteenman/zsh-aws-vault
antibody update
```

### [Zgen](https://github.com/tarjoilija/zgen)

```
zgen load dannysteenman/zsh-aws-vault
```

### [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)


1. Clone this repository into oh-my-zsh's plugins directory:
```
git clone https://github.com/dannysteenman/zsh-aws-vault.git \
  ~/.oh-my-zsh/custom/plugins/zsh-aws-vault
```

2. Activate the plugin in `~/.zshrc`:

```
plugins=( [plugins...] zsh-aws-vault)
```

## Features

It contains the following features:

- aliases
- cli functions

### Aliases

| Alias       | Expression         |
| ----------- | ------------------ |
| av          | aws-vault          |
| ave         | aws-vault exec     |
| avl         | aws-vault login    |
| avll        | aws-vault login -s |
| avs         | aws-vault server   |
| [avc](#avc) | aws-vault-chrome   |
| [avp](#avp) | aws-vault-profile  |

### `avc`

`avc` invokes the function `aws-vault-chrome` and allows you to login to the AWS Console from the Chrome browser in a new window.

To login to the AWS Console:
```zsh
avc <profile_name>
```

### `avp`

`avp` invokes the function `aws-vault-profile` and allows you to login from an aws profile and exports the temporary credentials.

To login to a profile in the cli:
```zsh
avp <profile_name>
```

To stop your session run `avp` without argument.
