package com.crescentflare.unilayout.helpers;

/**
 * UniLayout helper: a scroll listener
 * Used for scrollable views to listen for scroll position changes
 */
public interface UniScrollListener
{
    void onScrollChanged(int x, int y, int oldX, int oldY);
}
