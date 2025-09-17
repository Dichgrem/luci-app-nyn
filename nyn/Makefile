include $(TOPDIR)/rules.mk

PKG_NAME:=nyn
PKG_VERSION:=0.0.3
PKG_RELEASE:=1

PKG_MAINTAINER:=Dichgrem <brcefy@gmail.com>
PKG_LICENSE:=MIT

include $(INCLUDE_DIR)/package.mk

define Package/nyn
  SECTION:=net
  CATEGORY:=Network
  TITLE:=NYN 802.1x Authentication Client
  URL:=https://github.com/diredocks/nyn
  DEPENDS:=+libpcap
endef

define Package/nyn/description
  A 802.1x authentication client for OpenWrt routers.
  Cross-compiled with musl toolchain for optimal compatibility.
endef

define Package/nyn/conffiles
/etc/config/nyn
/etc/nyn/config.toml
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/nyn/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/nyn
	
	# Install precompiled binary based on architecture
	$(if $(CONFIG_TARGET_x86_64),$(INSTALL_BIN) ./files/bin/nyn-x86_64 $(1)/usr/bin/nyn)
	$(if $(CONFIG_TARGET_armvirt_64),$(INSTALL_BIN) ./files/bin/nyn-aarch64 $(1)/usr/bin/nyn)
	$(if $(CONFIG_TARGET_bcm27xx_bcm2711),$(INSTALL_BIN) ./files/bin/nyn-aarch64 $(1)/usr/bin/nyn)
	$(if $(CONFIG_TARGET_ath79_generic),$(INSTALL_BIN) ./files/bin/nyn-mips64 $(1)/usr/bin/nyn)
	$(if $(CONFIG_TARGET_ramips_mt7621),$(INSTALL_BIN) ./files/bin/nyn-mips64 $(1)/usr/bin/nyn)
	$(if $(CONFIG_TARGET_mediatek_mt7622),$(INSTALL_BIN) ./files/bin/nyn-aarch64 $(1)/usr/bin/nyn)
	$(if $(CONFIG_TARGET_rockchip_armv8),$(INSTALL_BIN) ./files/bin/nyn-aarch64 $(1)/usr/bin/nyn)
	# Fallback - try to detect architecture
	$(if $(findstring arm,$(ARCH)),$(INSTALL_BIN) ./files/bin/nyn-armv7 $(1)/usr/bin/nyn)
	$(if $(findstring aarch64,$(ARCH)),$(INSTALL_BIN) ./files/bin/nyn-aarch64 $(1)/usr/bin/nyn)
	$(if $(findstring mips,$(ARCH)),$(INSTALL_BIN) ./files/bin/nyn-mips64 $(1)/usr/bin/nyn)
	$(if $(findstring x86_64,$(ARCH)),$(INSTALL_BIN) ./files/bin/nyn-x86_64 $(1)/usr/bin/nyn)
	$(if $(findstring i386,$(ARCH)),$(INSTALL_BIN) ./files/bin/nyn-i686 $(1)/usr/bin/nyn)
	
	$(INSTALL_BIN) ./files/usr/bin/nyn-device-info $(1)/usr/bin/
	$(INSTALL_CONF) ./files/etc/config/nyn $(1)/etc/config/
	$(INSTALL_CONF) ./files/etc/nyn/config.toml $(1)/etc/nyn/
	$(INSTALL_BIN) ./files/etc/init.d/nyn $(1)/etc/init.d/
endef

$(eval $(call BuildPackage,nyn))
