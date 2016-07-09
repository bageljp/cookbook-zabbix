What's ?
===============
chef で使用する Zabbix の cookbook です。

Usage
-----
cookbook なので berkshelf で取ってきて使いましょう。

* Berksfile
```ruby
source "https://supermarket.chef.io"

cookbook "zabbix", git: "https://github.com/bageljp/cookbook-zabbix.git"
```

```
berks vendor
```

#### Role and Environment attributes

* sample_role.rb
```ruby
override_attributes(
  "zabbix" => {
    "agent" => {
      "server_ip" => "zabbix.example.com",
      "hostname" => ""
    }
  }
)
```

Recipes
----------

#### zabbix::default
zabbixリポジトリを設定。

#### zabbix::server
zabbix-server のインストールと設定。

#### zabbix::agent
zabbix-agent のインストールと設定。

#### zabbix::proxy
zabbix-proxy のインストールと設定。

#### zabbix::postfix
postfix を監視する場合、zabbix-agent側にpostfixの詳細情報取得の設定を行う。

#### zabbix::mysql
MySQL を監視する場合、zabbix-agent側にMySQLの詳細情報取得の設定を行う。

Attributes
----------

主要なやつのみ。

#### zabbix::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><tt>['zabbix']['server']['web']</tt></td>
    <td>string</td>
    <td>zabbix-server を動かすwebサーバ（apacheやnginxなど）の起動ユーザを指定。ファイルやディレクトリのパーミッションに影響。</td>
  </tr>
  <tr>
    <td><tt>['zabbix']['agent']['hostname']</tt></td>
    <td>string</td>
    <td>zabbixに登録される zabbix-agent のホスト名。空白にした場合、EC2インスタンスのNameタグをホスト名にする。監視対象ホストが自動で増減する場合などに。</td>
  </tr>
  <tr>
    <td><tt>['zabbix']['agent']['region']</tt></td>
    <td>string</td>
    <td>上記のEC2インスタンスのNameタグをホスト名にする場合にAPIでNameタグを参照するために必要。それ以外だと必要ない。</td>
  </tr>
  <tr>
    <td><tt>['zabbix']['mysql']['user']</tt></td>
    <td>string</td>
    <td>zabbixに監視されるMySQLのユーザ名。指定したユーザは ``SELECT, PROCESS, SHOW DATABASES, SUPER, REPLICATION CLIENT`` 権限が必要。</td>
  </tr>
</table>

