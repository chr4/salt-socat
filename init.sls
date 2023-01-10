socat:
  pkg.installed: []
  user.present:
    - home: /nonexistent
    - system: true

{% for name, config in pillar['socat'] | dictsort %}
/etc/systemd/system/socat-{{ name }}.service:
  service.running:
    - name: socat-{{ name }}
    - enable: true
    - watch:
      - file: /etc/systemd/system/socat-{{ name }}.service
    - require:
      - file: /etc/systemd/system/socat-{{ name }}.service
      - cmd: systemctl daemon-reload
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://{{ tpldir }}/socat.service.jinja
    - template: jinja
    - defaults:
      src: {{ config['source'] }}
      dst: {{ config['destination'] }}
      opt: {{ config['options']|default('""') }}
      user: socat
    - require:
      - user: socat
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: /etc/systemd/system/socat-{{ name }}.service
{% endfor %}
