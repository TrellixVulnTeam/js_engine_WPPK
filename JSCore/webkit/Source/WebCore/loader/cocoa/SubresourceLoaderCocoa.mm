/*
 * Copyright (C) 2014 Apple Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE INC. AND ITS CONTRIBUTORS ``AS IS''
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL APPLE INC. OR ITS CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "config.h"
#include "SubresourceLoader.h"

#include "CachedResource.h"
#include "DiskCacheMonitorCocoa.h"
#include "ResourceHandle.h"
#include "ResourceLoader.h"
#include "SharedBuffer.h"
#include <pal/spi/cf/CFNetworkSPI.h>

namespace WebCore {

#if USE(CFURLCONNECTION)

CFCachedURLResponseRef SubresourceLoader::willCacheResponse(ResourceHandle* handle, CFCachedURLResponseRef cachedResponse)
{
    DiskCacheMonitor::monitorFileBackingStoreCreation(request(), m_resource->sessionID(), cachedResponse);
    if (!m_resource->shouldCacheResponse(CFCachedURLResponseGetWrappedResponse(cachedResponse)))
        return nullptr;
    return ResourceLoader::willCacheResponse(handle, cachedResponse);
}

#else

NSCachedURLResponse* SubresourceLoader::willCacheResponse(ResourceHandle* handle, NSCachedURLResponse* response)
{
    DiskCacheMonitor::monitorFileBackingStoreCreation(request(), m_resource->sessionID(), [response _CFCachedURLResponse]);
    if (!m_resource->shouldCacheResponse(response.response))
        return nullptr;
    return ResourceLoader::willCacheResponse(handle, response);
}

#endif

}
