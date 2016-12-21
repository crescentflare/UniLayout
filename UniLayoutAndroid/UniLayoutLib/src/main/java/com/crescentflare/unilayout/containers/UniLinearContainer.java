package com.crescentflare.unilayout.containers;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Point;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import com.crescentflare.unilayout.R;
import com.crescentflare.unilayout.helpers.UniLayoutParams;
import com.crescentflare.unilayout.views.UniView;

import java.util.ArrayList;
import java.util.List;

/**
 * UniLayout container: a vertically or horizontally aligned view container
 * Stacks views below or to the right of each other
 */
public class UniLinearContainer extends ViewGroup
{
    // ---
    // Constants
    // ---

    public static final int VERTICAL = LinearLayout.VERTICAL;
    public static final int HORIZONTAL = LinearLayout.HORIZONTAL;


    // ---
    // Members
    // ---

    int orientation = VERTICAL;


    // ---
    // Initialization
    // ---

    public UniLinearContainer(Context context)
    {
        this(context, (AttributeSet)null);
    }

    public UniLinearContainer(Context context, AttributeSet attrs)
    {
        super(context, attrs);
        init(attrs);
    }

    public UniLinearContainer(Context context, AttributeSet attrs, int defStyleAttr)
    {
        this(context, attrs);
    }

    public UniLinearContainer(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes)
    {
        this(context, attrs);
    }

    private void init(AttributeSet attrs)
    {
        if (attrs != null)
        {
            TypedArray a = getContext().obtainStyledAttributes(attrs, R.styleable.UniLinearContainer);
            orientation = a.getInt(R.styleable.UniLinearContainer_uni_orientation, VERTICAL);
            a.recycle();
        }
    }

    @Override
    protected LayoutParams generateDefaultLayoutParams()
    {
        return new UniLayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
    }

    @Override
    public LayoutParams generateLayoutParams(AttributeSet attrs)
    {
        return new UniLayoutParams(getContext(), attrs);
    }


    // ---
    // Adjust properties
    // ---

    public int getOrientation()
    {
        return orientation;
    }

    public void setOrientation(int orientation)
    {
        this.orientation = orientation;
    }


    // ---
    // Custom layout
    // ---

    private Point measuredSize = new Point();

    private void performVerticalLayout(Point measuredSize, int widthSize, int heightSize, int widthSpec, int heightSpec, boolean adjustLayout)
    {
        // Determine available size without padding
        int paddedWidthSize = widthSize - getPaddingLeft() - getPaddingRight();
        int paddedHeightSize = heightSize - getPaddingTop() - getPaddingBottom();
        measuredSize.x = getPaddingLeft();
        measuredSize.y = getPaddingTop();
        if (widthSpec == MeasureSpec.UNSPECIFIED)
        {
            paddedWidthSize = 0xFFFFFF;
        }
        if (heightSpec == MeasureSpec.UNSPECIFIED)
        {
            paddedHeightSize = 0xFFFFFF;
        }

        // Measure the views without any weight
        float totalWeight = 0;
        int remainingHeight = paddedHeightSize;
        float totalMinHeightForWeight = 0;
        int childCount = getChildCount();
        for (int i = 0; i < childCount; i++)
        {
            // Skip hidden views if they are not part of the layout
            View view = getChildAt(i);
            if (view.getVisibility() == GONE)
            {
                continue;
            }

            // Skip views with weight, they will go in the second phase
            ViewGroup.LayoutParams viewLayoutParams = view.getLayoutParams();
            if (viewLayoutParams instanceof UniLayoutParams)
            {
                UniLayoutParams uniLayoutParams = (UniLayoutParams)viewLayoutParams;
                if (uniLayoutParams.weight > 0)
                {
                    totalWeight += uniLayoutParams.weight;
                    remainingHeight -= uniLayoutParams.topMargin + uniLayoutParams.bottomMargin + uniLayoutParams.minHeight;
                    totalMinHeightForWeight += uniLayoutParams.minHeight;
                    continue;
                }
            }

            // Perform measure and update remaining height
            int limitWidth = paddedWidthSize;
            if (viewLayoutParams instanceof MarginLayoutParams)
            {
                limitWidth -= ((MarginLayoutParams)viewLayoutParams).leftMargin + ((MarginLayoutParams)viewLayoutParams).rightMargin;
                remainingHeight -= ((MarginLayoutParams)viewLayoutParams).topMargin + ((MarginLayoutParams)viewLayoutParams).bottomMargin;
            }
            UniView.uniMeasure(view, limitWidth, remainingHeight, widthSpec, heightSpec, MeasureSpec.UNSPECIFIED, MeasureSpec.UNSPECIFIED);
            remainingHeight = Math.max(0, remainingHeight - view.getMeasuredHeight());
        }

        // Measure the remaining views with weight
        remainingHeight += totalMinHeightForWeight;
        for (int i = 0; i < childCount; i++)
        {
            // Skip hidden views if they are not part of the layout
            View view = getChildAt(i);
            if (view.getVisibility() == GONE)
            {
                continue;
            }

            // Continue measuring views with weight
            if (view.getLayoutParams() instanceof UniLayoutParams)
            {
                UniLayoutParams uniLayoutParams = (UniLayoutParams)view.getLayoutParams();
                if (uniLayoutParams.weight > 0)
                {
                    int forceViewHeightSpec = heightSpec == MeasureSpec.EXACTLY ? MeasureSpec.EXACTLY : MeasureSpec.UNSPECIFIED;
                    UniView.uniMeasure(view, paddedWidthSize - uniLayoutParams.leftMargin - uniLayoutParams.rightMargin, (int)(remainingHeight * uniLayoutParams.weight / totalWeight), widthSpec, heightSpec, MeasureSpec.UNSPECIFIED, forceViewHeightSpec);
                    remainingHeight = Math.max(0, remainingHeight - view.getMeasuredHeight());
                    totalWeight -= uniLayoutParams.weight;
                }
            }
        }

        // Start doing layout
        int y = getPaddingTop();
        for (int i = 0; i < childCount; i++)
        {
            // Skip hidden views if they are not part of the layout
            View view = getChildAt(i);
            if (view.getVisibility() == GONE)
            {
                continue;
            }

            // Continue with the others
            int width = view.getMeasuredWidth();
            int height = view.getMeasuredHeight();
            int x = getPaddingLeft();
            int nextY = y;
            if (view.getLayoutParams() instanceof UniLayoutParams)
            {
                UniLayoutParams uniLayoutParams = (UniLayoutParams)view.getLayoutParams();
                x += uniLayoutParams.leftMargin;
                y += uniLayoutParams.topMargin;
                if (adjustLayout)
                {
                    x += (paddedWidthSize - uniLayoutParams.leftMargin - uniLayoutParams.rightMargin - width) * uniLayoutParams.horizontalGravity;
                }
                measuredSize.x = Math.max(measuredSize.x, x + width + uniLayoutParams.rightMargin);
                nextY = y + height + uniLayoutParams.bottomMargin;
            }
            else
            {
                measuredSize.x = Math.max(measuredSize.x, x + width);
                nextY = y + height;
            }
            if (adjustLayout)
            {
                view.layout(x, y, x + width, y + height);
            }
            measuredSize.y = Math.max(measuredSize.y, nextY);
            y = nextY;
        }

        // Adjust final measure with padding and limitations
        measuredSize.x += getPaddingRight();
        measuredSize.y += getPaddingBottom();
        if (widthSpec == MeasureSpec.EXACTLY)
        {
            measuredSize.x = widthSize;
        }
        else if (widthSpec == MeasureSpec.AT_MOST)
        {
            measuredSize.x = Math.min(measuredSize.x, widthSize);
        }
        if (heightSpec == MeasureSpec.EXACTLY)
        {
            measuredSize.y = heightSize;
        }
        else if (heightSpec == MeasureSpec.AT_MOST)
        {
            measuredSize.y = Math.min(measuredSize.y, heightSize);
        }
    }

    private void performHorizontalLayout(Point measuredSize, int widthSize, int heightSize, int widthSpec, int heightSpec, boolean adjustLayout)
    {
        // Determine available size without padding
        int paddedWidthSize = widthSize - getPaddingLeft() - getPaddingRight();
        int paddedHeightSize = heightSize - getPaddingTop() - getPaddingBottom();
        measuredSize.x = getPaddingLeft();
        measuredSize.y = getPaddingTop();
        if (widthSpec == MeasureSpec.UNSPECIFIED)
        {
            paddedWidthSize = 0xFFFFFF;
        }
        if (heightSpec == MeasureSpec.UNSPECIFIED)
        {
            paddedHeightSize = 0xFFFFFF;
        }

        // Measure the views without any weight
        float totalWeight = 0;
        int remainingWidth = paddedWidthSize;
        float totalMinWidthForWeight = 0;
        int childCount = getChildCount();
        for (int i = 0; i < childCount; i++)
        {
            // Skip hidden views if they are not part of the layout
            View view = getChildAt(i);
            if (view.getVisibility() == GONE)
            {
                continue;
            }

            // Skip views with weight, they will go in the second phase
            ViewGroup.LayoutParams viewLayoutParams = view.getLayoutParams();
            if (viewLayoutParams instanceof UniLayoutParams)
            {
                UniLayoutParams uniLayoutParams = (UniLayoutParams)viewLayoutParams;
                if (uniLayoutParams.weight > 0)
                {
                    totalWeight += uniLayoutParams.weight;
                    remainingWidth -= uniLayoutParams.leftMargin + uniLayoutParams.rightMargin + uniLayoutParams.minWidth;
                    totalMinWidthForWeight += uniLayoutParams.minWidth;
                    continue;
                }
            }

            // Perform measure and update remaining height
            int limitHeight = paddedHeightSize;
            if (viewLayoutParams instanceof MarginLayoutParams)
            {
                remainingWidth -= ((MarginLayoutParams)viewLayoutParams).leftMargin + ((MarginLayoutParams)viewLayoutParams).rightMargin;
                limitHeight -= ((MarginLayoutParams)viewLayoutParams).topMargin + ((MarginLayoutParams)viewLayoutParams).bottomMargin;
            }
            UniView.uniMeasure(view, remainingWidth, limitHeight, widthSpec, heightSpec, MeasureSpec.UNSPECIFIED, MeasureSpec.UNSPECIFIED);
            remainingWidth = Math.max(0, remainingWidth - view.getMeasuredWidth());
        }

        // Measure the remaining views with weight
        remainingWidth += totalMinWidthForWeight;
        for (int i = 0; i < childCount; i++)
        {
            // Skip hidden views if they are not part of the layout
            View view = getChildAt(i);
            if (view.getVisibility() == GONE)
            {
                continue;
            }

            // Continue with views with weight
            if (view.getLayoutParams() instanceof UniLayoutParams)
            {
                UniLayoutParams uniLayoutParams = (UniLayoutParams)view.getLayoutParams();
                if (uniLayoutParams.weight > 0)
                {
                    int forceViewWidthSpec = widthSpec == MeasureSpec.EXACTLY ? MeasureSpec.EXACTLY : MeasureSpec.UNSPECIFIED;
                    UniView.uniMeasure(view, (int)(remainingWidth * uniLayoutParams.weight / totalWeight), paddedHeightSize - uniLayoutParams.topMargin - uniLayoutParams.bottomMargin, widthSpec, heightSpec, forceViewWidthSpec, MeasureSpec.UNSPECIFIED);
                    remainingWidth = Math.max(0, remainingWidth - view.getMeasuredWidth());
                    totalWeight -= uniLayoutParams.weight;
                }
            }
        }

        // Start doing layout
        int x = getPaddingLeft();
        for (int i = 0; i < childCount; i++)
        {
            // Skip hidden views if they are not part of the layout
            View view = getChildAt(i);
            if (view.getVisibility() == GONE)
            {
                continue;
            }

            // Continue with the others
            int width = view.getMeasuredWidth();
            int height = view.getMeasuredHeight();
            int y = getPaddingTop();
            int nextX = x;
            if (view.getLayoutParams() instanceof UniLayoutParams)
            {
                UniLayoutParams uniLayoutParams = (UniLayoutParams)view.getLayoutParams();
                x += uniLayoutParams.leftMargin;
                y += uniLayoutParams.topMargin;
                if (adjustLayout)
                {
                    y += (paddedHeightSize - uniLayoutParams.topMargin - uniLayoutParams.bottomMargin - height) * uniLayoutParams.verticalGravity;
                }
                measuredSize.y = Math.max(measuredSize.y, y + height + uniLayoutParams.bottomMargin);
                nextX = x + width + uniLayoutParams.rightMargin;
            }
            else
            {
                measuredSize.y = Math.max(measuredSize.y, y + height);
                nextX = x + width;
            }
            if (adjustLayout)
            {
                view.layout(x, y, x + width, y + height);
            }
            measuredSize.x = Math.max(measuredSize.x, nextX);
            x = nextX;
        }

        // Adjust final measure with padding and limitations
        measuredSize.x += getPaddingRight();
        measuredSize.y += getPaddingBottom();
        if (widthSpec == MeasureSpec.EXACTLY)
        {
            measuredSize.x = widthSize;
        }
        else if (widthSpec == MeasureSpec.AT_MOST)
        {
            measuredSize.x = Math.min(measuredSize.x, widthSize);
        }
        if (heightSpec == MeasureSpec.EXACTLY)
        {
            measuredSize.y = heightSize;
        }
        else if (heightSpec == MeasureSpec.AT_MOST)
        {
            measuredSize.y = Math.min(measuredSize.y, heightSize);
        }
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec)
    {
        if (getOrientation() == VERTICAL)
        {
            performVerticalLayout(measuredSize, MeasureSpec.getSize(widthMeasureSpec), MeasureSpec.getSize(heightMeasureSpec), MeasureSpec.getMode(widthMeasureSpec), MeasureSpec.getMode(heightMeasureSpec), false);
            setMeasuredDimension(measuredSize.x, measuredSize.y);
        }
        else
        {
            performHorizontalLayout(measuredSize, MeasureSpec.getSize(widthMeasureSpec), MeasureSpec.getSize(heightMeasureSpec), MeasureSpec.getMode(widthMeasureSpec), MeasureSpec.getMode(heightMeasureSpec), false);
            setMeasuredDimension(measuredSize.x, measuredSize.y);
        }
    }

    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom)
    {
        if (getOrientation() == VERTICAL)
        {
            performVerticalLayout(measuredSize, right - left, bottom - top, MeasureSpec.EXACTLY, MeasureSpec.EXACTLY, true);
        }
        else
        {
            performHorizontalLayout(measuredSize, right - left, bottom - top, MeasureSpec.EXACTLY, MeasureSpec.EXACTLY, true);
        }
    }
}
