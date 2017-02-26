package com.crescentflare.unilayout.helpers;

import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;

import com.crescentflare.unilayout.R;

/**
 * UniLayout helper: general layout utilities
 * Provides shared helper functions for measurement and layout
 */
public class UniLayout
{
    // ---
    // Utility
    // ---

    public static void measure(View view, int viewWidthSize, int viewHeightSize, int parentWidthSpec, int parentHeightSpec, int viewWidthSpec, int viewHeightSpec)
    {
        // Derive view spec from parent
        ViewGroup.LayoutParams viewLayoutParams = view.getLayoutParams();
        if (viewWidthSpec == View.MeasureSpec.UNSPECIFIED)
        {
            viewWidthSpec = parentWidthSpec == View.MeasureSpec.UNSPECIFIED ? View.MeasureSpec.UNSPECIFIED : View.MeasureSpec.AT_MOST;
        }
        if (viewHeightSpec == View.MeasureSpec.UNSPECIFIED)
        {
            viewHeightSpec = parentHeightSpec == View.MeasureSpec.UNSPECIFIED ? View.MeasureSpec.UNSPECIFIED : View.MeasureSpec.AT_MOST;
        }
        if (parentWidthSpec == View.MeasureSpec.EXACTLY && viewLayoutParams.width == ViewGroup.LayoutParams.MATCH_PARENT)
        {
            viewWidthSpec = View.MeasureSpec.EXACTLY;
        }
        if (parentHeightSpec == View.MeasureSpec.EXACTLY && viewLayoutParams.height == ViewGroup.LayoutParams.MATCH_PARENT)
        {
            viewHeightSpec = View.MeasureSpec.EXACTLY;
        }

        // Determine sizing limits
        int viewMinWidth = 0;
        int viewMaxWidth = 0xFFFFFF;
        int viewMinHeight = 0;
        int viewMaxHeight = 0xFFFFFF;
        if (viewLayoutParams instanceof UniLayoutParams)
        {
            viewMinWidth = Math.max(0, ((UniLayoutParams)viewLayoutParams).minWidth);
            viewMaxWidth = ((UniLayoutParams)viewLayoutParams).maxWidth;
            viewMinHeight = Math.max(0, ((UniLayoutParams)viewLayoutParams).minHeight);
            viewMaxHeight = ((UniLayoutParams)viewLayoutParams).maxHeight;
        }

        // Adjust size to measure on based on view limits or forced values
        if (viewWidthSpec == View.MeasureSpec.EXACTLY)
        {
            viewWidthSize = Math.min(viewWidthSize, Math.max(viewMinWidth, viewMaxWidth));
        }
        else if (viewLayoutParams.width >= 0)
        {
            viewWidthSize = Math.min(viewWidthSize, Math.max(viewMinWidth, Math.min(viewLayoutParams.width, viewMaxWidth)));
            viewWidthSpec = View.MeasureSpec.EXACTLY;
        }
        else
        {
            viewWidthSize = Math.min(viewWidthSize, Math.max(viewMinWidth, viewMaxWidth));
        }
        if (viewHeightSpec == View.MeasureSpec.EXACTLY)
        {
            viewHeightSize = Math.min(viewHeightSize, Math.max(viewMinHeight, viewMaxHeight));
        }
        else if (viewLayoutParams.height >= 0)
        {
            viewHeightSize = Math.min(viewHeightSize, Math.max(viewMinHeight, Math.min(viewLayoutParams.height, viewMaxHeight)));
            viewHeightSpec = View.MeasureSpec.EXACTLY;
        }
        else
        {
            viewHeightSize = Math.min(viewHeightSize, Math.max(viewMinHeight, viewMaxHeight));
        }

        // Perform first measure and apply forced exact measure again if size restrictions are in place
        view.measure(View.MeasureSpec.makeMeasureSpec(viewWidthSize, viewWidthSpec), View.MeasureSpec.makeMeasureSpec(viewHeightSize, viewHeightSpec));
        int resultWidth = view.getMeasuredWidth();
        int resultHeight = view.getMeasuredHeight();
        resultWidth = Math.min(viewWidthSize, Math.max(viewMinWidth, resultWidth));
        resultHeight = Math.min(viewHeightSize, Math.max(viewMinHeight, resultHeight));
        if (resultWidth != view.getMeasuredWidth() || resultHeight != view.getMeasuredHeight())
        {
            view.measure(View.MeasureSpec.makeMeasureSpec(resultWidth, View.MeasureSpec.EXACTLY), View.MeasureSpec.makeMeasureSpec(resultHeight, View.MeasureSpec.EXACTLY));
        }
    }
}
