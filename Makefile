include $(TOPDIR)/rules.mk

PKG_NAME:=UnblockNeteaseGo
PKG_VERSION:=0.2.14
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/cnsilvan/UnblockNeteaseMusic.git
PKG_MAINTAINER:=Silvan <cnsilvan@gmail.com>

PKG_SOURCE_SUBDIR:=$(PKG_NAME)
PKG_SOURCE:=$(PKG_SOURCE_SUBDIR)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)


PKG_BUILD_DEPENDS:=golang/host upx/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/cnsilvan/UnblockNeteaseMusic
GO_PKG_LDFLAGS:=-s -w
COMPILE_TIME := $(shell TZ=UTC-8 date '+%Y-%m-%d %H:%M:%S')
GO_PKG_LDFLAGS+= \
	-X '$(GO_PKG)/version.Version=$(PKG_VERSION)' \
	-X '$(GO_PKG)/version.BuildTime=$(COMPILE_TIME)' 
include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Revive unavailable songs for Netease Music (Golang)
	URL:=https://github.com/cnsilvan/UnblockNeteaseMusic
	DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/$(PKG_NAME)/description
	Revive unavailable songs for Netease Music (Golang)
endef

define Build/Prepare
	tar -zxvf $(DL_DIR)/$(PKG_SOURCE) -C $(BUILD_DIR)/$(PKG_NAME) --strip-components 1
endef

define Build/Compile
	$(eval GO_PKG_BUILD_PKG:=$(GO_PKG))
	$(call GoPackage/Build/Configure)
	$(eval GO_PKG_LDFLAGS+=-X '$(GO_PKG)/version.ExGoVersionInfo=$(GO_ARM) $(GO_MIPS)$(GO_MIPS64)')
	$(call GoPackage/Build/Compile)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/UnblockNeteaseMusic
	chmod +wx $(GO_PKG_BUILD_BIN_DIR)/UnblockNeteaseMusic
endef

define Package/UnblockNeteaseGo/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/UnblockNeteaseMusic $(1)/usr/bin/UnblockNeteaseGo
	
endef

$(eval $(call GoBinPackage,UnblockNeteaseGo))
$(eval $(call BuildPackage,UnblockNeteaseGo))
