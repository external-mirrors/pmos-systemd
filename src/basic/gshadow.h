#pragma once

#ifndef ENABLE_GSHADOW
#       define ENABLE_GSHADOW 0
#endif

#if ENABLE_GSHADOW
#       include <gshadow.h>
#else
        struct sgrp {};
#endif
