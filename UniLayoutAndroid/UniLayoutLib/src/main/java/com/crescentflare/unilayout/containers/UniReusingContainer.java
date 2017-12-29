package com.crescentflare.unilayout.containers;

import android.content.Context;
import android.graphics.Point;
import android.os.Build;
import android.os.Handler;
import android.os.SystemClock;
import android.support.v4.view.MotionEventCompat;
import android.support.v4.view.ViewConfigurationCompat;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.VelocityTracker;
import android.view.View;
import android.view.ViewConfiguration;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ScrollView;

import com.crescentflare.unilayout.helpers.UniScrollListener;
import com.crescentflare.unilayout.views.UniReusableView;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * UniLayout container: a container with reusable views
 * Extends the (vertical) scrollview with the ability to add multiple views which can be reused
 */
public class UniReusingContainer extends ScrollView
{
    // ---
    // Members
    // ---

    private LayoutContainer contentView;
    private UniScrollListener scrollListener;
    private DragState dragState = DragState.Idle;
    private VelocityTracker velocityTracker;
    private int draggingPosition = -1;
    private int touchCounter = 0;
    private int touchSlop;
    private int minFlingVelocity;
    private int maxFlingVelocity;
    private int longPressTimeout;
    private float startDragX;
    private float startDragY;
    private boolean multiSelect;


    // ---
    // Initialization
    // ---

    public UniReusingContainer(Context context)
    {
        this(context, (AttributeSet)null);
    }

    public UniReusingContainer(Context context, AttributeSet attrs)
    {
        super(context, attrs);
        init(attrs);
    }

    public UniReusingContainer(Context context, AttributeSet attrs, int defStyleAttr)
    {
        this(context, attrs);
    }

    public UniReusingContainer(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes)
    {
        this(context, attrs);
    }

    private void init(AttributeSet attrs)
    {
        final ViewConfiguration configuration = ViewConfiguration.get(getContext());
        touchSlop = ViewConfigurationCompat.getScaledPagingTouchSlop(configuration);
        minFlingVelocity = configuration.getScaledMinimumFlingVelocity();
        maxFlingVelocity = configuration.getScaledMaximumFlingVelocity();
        longPressTimeout = ViewConfiguration.getLongPressTimeout();
    }


    // ---
    // Data handling
    // ---

    public Adapter getAdapter()
    {
        if (contentView != null)
        {
            return contentView.adapter;
        }
        return null;
    }

    public void setAdapter(Adapter adapter)
    {
        // Remove content view when removing the adapter
        if (adapter == null && contentView != null)
        {
            removeView(contentView);
            contentView = null;
        }

        // Add the content view if setting an adapter
        boolean newCreated = false;
        if (adapter != null && contentView == null)
        {
            contentView = new LayoutContainer(getContext());
            contentView.setLayoutParams(new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
            addView(contentView);
            contentView.setAdapter(adapter);
            contentView.setMultiSelect(multiSelect);
            newCreated = true;
        }

        // Refresh if needed
        if (contentView != null && (contentView.adapter != adapter || newCreated))
        {
            contentView.refreshCalculation();
            requestLayout();
        }
    }

    public int getAdapterPosition(UniReusableView view)
    {
        int index = 0;
        for (UsingView usingView : contentView.usingViews)
        {
            if (usingView.view == view)
            {
                return contentView.usingViewStartPosition + index;
            }
            index++;
        }
        return -1;
    }

    public void setMultiSelect(boolean enabled)
    {
        multiSelect = enabled;
        if (contentView != null)
        {
            contentView.setMultiSelect(multiSelect);
        }
    }

    public boolean isMultiSelect()
    {
        return multiSelect;
    }


    // ---
    // Scroll handling
    // ---

    public void setScrollListener(UniScrollListener scrollListener)
    {
        this.scrollListener = scrollListener;
    }

    @Override
    protected void onScrollChanged(int x, int y, int oldX, int oldY)
    {
        super.onScrollChanged(x, y, oldX, oldY);
        if (scrollListener != null)
        {
            scrollListener.onScrollChanged(x, y, oldX, oldY);
        }
        if (contentView != null)
        {
            contentView.setOffsetY(y);
        }
        touchCounter++;
    }

    public void scrollToPosition(int itemPosition)
    {
        scrollToPosition(itemPosition, 0.5f);
    }

    public void scrollToPosition(int itemPosition, float locationInView)
    {
        if (getHeight() > 0 && getWidth() > 0 && contentView.getReusableViewCount() > 0)
        {
            int scrollAreaHeight = Math.max(0, getHeight() - getPaddingTop() - getPaddingBottom());
            int toPosition = Math.max(0, Math.min(itemPosition, contentView.getReusableViewCount() - 1));
            scrollTo(0, contentView.getReusableViewY(toPosition) - (int)(locationInView * (scrollAreaHeight - contentView.getEstimatedHeight(toPosition))));
        }
    }

    public void smoothScrollToPosition(int itemPosition)
    {
        smoothScrollToPosition(itemPosition, 0.5f);
    }

    public void smoothScrollToPosition(int itemPosition, float locationInView)
    {
        if (getHeight() > 0 && getWidth() > 0 && contentView.getReusableViewCount() > 0)
        {
            int scrollAreaHeight = Math.max(0, getHeight() - getPaddingTop() - getPaddingBottom());
            int toPosition = Math.max(0, Math.min(itemPosition, contentView.getReusableViewCount() - 1));
            smoothScrollTo(0, contentView.getReusableViewY(toPosition) - (int)(locationInView * (scrollAreaHeight - contentView.getEstimatedHeight(toPosition))));
        }
    }


    // ---
    // Touch and swipe handling
    // ---

    @Override
    public boolean onInterceptTouchEvent(MotionEvent event)
    {
        int action = MotionEventCompat.getActionMasked(event);
        final float x = event.getX();
        final float y = event.getY();
        switch (action)
        {
            case MotionEvent.ACTION_DOWN:
            {
                int index = 0;
                dragState = DragState.Idle;
                startDragX = x;
                startDragY = y;
                draggingPosition = -1;
                for (UsingView usingView : contentView.usingViews)
                {
                    if (usingView.view != null && startDragY + getScrollY() >= usingView.view.getTop() && startDragY + getScrollY() < usingView.view.getBottom())
                    {
                        if (usingView.view.getUnderView() != null)
                        {
                            draggingPosition = index + contentView.usingViewStartPosition;
                            velocityTracker = VelocityTracker.obtain();
                            velocityTracker.addMovement(event);
                        }
                        break;
                    }
                    index++;
                }
                touchCounter++;
                if (draggingPosition >= 0)
                {
                    final int checkTouchCounter = touchCounter;
                    new Handler().postDelayed(new Runnable()
                    {
                        @Override
                        public void run()
                        {
                            if (checkTouchCounter == touchCounter)
                            {
                                if (draggingPosition >= contentView.usingViewStartPosition && draggingPosition < contentView.usingViewStartPosition + contentView.usingViews.size())
                                {
                                    MotionEvent cancelMotion = MotionEvent.obtain(SystemClock.uptimeMillis(), SystemClock.uptimeMillis(), MotionEvent.ACTION_CANCEL, x, y, 0);
                                    dispatchTouchEvent(cancelMotion);
                                    cancelMotion.recycle();
                                    if (draggingPosition == getSwipedOpen())
                                    {
                                        closeSwipedOpen();
                                    }
                                    else
                                    {
                                        setSwipedOpen(draggingPosition);
                                    }
                                }
                            }
                        }
                    }, longPressTimeout);
                }
                break;
            }
            case MotionEvent.ACTION_MOVE:
                if (dragState == DragState.Idle)
                {
                    if (velocityTracker != null)
                    {
                        velocityTracker.addMovement(event);
                        velocityTracker.computeCurrentVelocity(1000);
                    }
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB)
                    {
                        if (Math.abs(startDragX - x) >= touchSlop && draggingPosition >= 0)
                        {
                            dragState = DragState.Swiping;
                            if (draggingPosition != getSwipedOpen())
                            {
                                closeSwipedOpen();
                            }
                            touchCounter++;
                            return true;
                        }
                    }
                    if (Math.abs(startDragY - y) >= touchSlop)
                    {
                        touchCounter++;
                        dragState = DragState.Scrolling;
                        break;
                    }
                }
                if (dragState == DragState.Swiping)
                {
                    return true;
                }
                break;
            case MotionEvent.ACTION_CANCEL:
                dragState = DragState.Idle;
                touchCounter++;
                break;
            case MotionEvent.ACTION_UP:
            {
                boolean wasIntercepted = dragState != DragState.Idle;
                dragState = DragState.Idle;
                touchCounter++;
                return wasIntercepted;
            }
            default:
                break;
        }
        return super.onInterceptTouchEvent(event);
    }

    @Override
    public boolean onTouchEvent(MotionEvent event)
    {
        // Handle touches for swiping
        int action = MotionEventCompat.getActionMasked(event);
        boolean handled = false;
        if (dragState == DragState.Swiping)
        {
            final float x = event.getX();
            switch (action)
            {
                case MotionEvent.ACTION_DOWN:
                    break; // Handled in interceptor
                case MotionEvent.ACTION_MOVE:
                    if (velocityTracker != null)
                    {
                        velocityTracker.addMovement(event);
                        velocityTracker.computeCurrentVelocity(1000);
                    }
                    if (draggingPosition >= contentView.usingViewStartPosition && draggingPosition < contentView.usingViewStartPosition + contentView.usingViews.size())
                    {
                        int index = draggingPosition - contentView.usingViewStartPosition;
                        if (draggingPosition == getSwipedOpen())
                        {
                            int viewWidth = contentView.usingViews.get(index).view.getWidth();
                            contentView.usingViews.get(index).view.setSwipeTranslationX(-viewWidth + Math.max(0, x - startDragX));
                        }
                        else
                        {
                            contentView.usingViews.get(index).view.setSwipeTranslationX(Math.min(0, x - startDragX));
                        }
                    }
                    break;
                case MotionEvent.ACTION_CANCEL:
                    if (velocityTracker != null)
                    {
                        velocityTracker.recycle();
                        velocityTracker = null;
                    }
                    if (draggingPosition >= contentView.usingViewStartPosition && draggingPosition < contentView.usingViewStartPosition + contentView.usingViews.size())
                    {
                        int index = draggingPosition - contentView.usingViewStartPosition;
                        if (draggingPosition == getSwipedOpen())
                        {
                            contentView.usingViews.get(index).view.swipeOpen(true);
                        }
                        else
                        {
                            contentView.usingViews.get(index).view.swipeClose(true);
                        }
                    }
                    break;
                case MotionEvent.ACTION_UP:
                {
                    boolean willSwipe = false;
                    if (velocityTracker != null && Math.abs(velocityTracker.getXVelocity()) > Math.abs(velocityTracker.getYVelocity()))
                    {
                        float checkVelocitySpeed = Math.abs(velocityTracker.getXVelocity());
                        if ((draggingPosition == getSwipedOpen() && velocityTracker.getXVelocity() > 0) || (draggingPosition != getSwipedOpen() && velocityTracker.getXVelocity() < 0))
                        {
                            willSwipe = checkVelocitySpeed >= minFlingVelocity && checkVelocitySpeed < maxFlingVelocity;
                        }
                    }
                    if (willSwipe)
                    {
                        if (draggingPosition == getSwipedOpen())
                        {
                            closeSwipedOpen();
                        }
                        else
                        {
                            setSwipedOpen(draggingPosition);
                        }
                    }
                    else
                    {
                        if (draggingPosition >= contentView.usingViewStartPosition && draggingPosition < contentView.usingViewStartPosition + contentView.usingViews.size())
                        {
                            int index = draggingPosition - contentView.usingViewStartPosition;
                            if (draggingPosition == getSwipedOpen())
                            {
                                contentView.usingViews.get(index).view.swipeOpen(true);
                            }
                            else
                            {
                                contentView.usingViews.get(index).view.swipeClose(true);
                            }
                        }
                    }
                    break;
                }
                default:
                    break;
            }
            handled = true;
        }
        if (action == MotionEvent.ACTION_UP || action == MotionEvent.ACTION_CANCEL)
        {
            touchCounter++;
        }

        // Main cleanup for up or cancel events
        if (velocityTracker != null && (action == MotionEvent.ACTION_CANCEL || action == MotionEvent.ACTION_UP))
        {
            velocityTracker.recycle();
            velocityTracker = null;
        }
        if (handled)
        {
            return true;
        }
        return super.onTouchEvent(event);
    }

    public void setSwipedOpen(int position)
    {
        // Do nothing if already open
        if (getSwipedOpen() == position)
        {
            return;
        }

        // Close view that was already open
        if (getSwipedOpen() >= 0 && getSwipedOpen() >= contentView.usingViewStartPosition && getSwipedOpen() < contentView.usingViewStartPosition + contentView.usingViews.size())
        {
            int index = getSwipedOpen() - contentView.usingViewStartPosition;
            contentView.usingViews.get(index).view.swipeClose(true);
        }
        if (getAdapter() != null)
        {
            getAdapter().itemSwipedOpen = -1;
        }

        // Open view
        if (getAdapter() != null)
        {
            getAdapter().itemSwipedOpen = position;
            if (getSwipedOpen() >= 0 && getSwipedOpen() >= contentView.usingViewStartPosition && getSwipedOpen() < contentView.usingViewStartPosition + contentView.usingViews.size())
            {
                int index = getSwipedOpen() - contentView.usingViewStartPosition;
                contentView.usingViews.get(index).view.swipeOpen(true);
            }
        }
    }

    public void closeSwipedOpen()
    {
        setSwipedOpen(-1);
    }

    private int getSwipedOpen()
    {
        if (getAdapter() != null)
        {
            return getAdapter().itemSwipedOpen;
        }
        return -1;
    }


    // ---
    // Get reusable views manually
    // ---

    public UniReusableView getReusableView(int position)
    {
        return getReusableView(position, false);
    }

    public UniReusableView getReusableView(int position, boolean includeAll)
    {
        return contentView.getReusableView(position, includeAll);
    }


    // ---
    // Forward padding from/into the content view
    // ---

    public void setContentPadding(int left, int top, int right, int bottom)
    {
        contentView.setPadding(left, top, right, bottom);
    }

    public int getContentPaddingTop()
    {
        return contentView.getPaddingTop();
    }

    public int getContentPaddingBottom()
    {
        return contentView.getPaddingBottom();
    }

    public int getContentPaddingLeft()
    {
        return contentView.getPaddingLeft();
    }

    public int getContentPaddingRight()
    {
        return contentView.getPaddingRight();
    }


    // ---
    // Custom layout
    // ---

    private Point measuredSize = new Point();

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec)
    {
        // Determine available size without padding
        int widthSpec = MeasureSpec.getMode(widthMeasureSpec);
        int heightSpec = MeasureSpec.getMode(heightMeasureSpec);
        int widthSize = MeasureSpec.getSize(widthMeasureSpec);
        int heightSize = MeasureSpec.getSize(heightMeasureSpec);
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

        // Measure items from adapter
        int childWidthSpec = MeasureSpec.AT_MOST;
        if (widthSpec == MeasureSpec.EXACTLY)
        {
            childWidthSpec = MeasureSpec.EXACTLY;
        }
        contentView.measure(MeasureSpec.makeMeasureSpec(paddedWidthSize, childWidthSpec), MeasureSpec.makeMeasureSpec(paddedHeightSize, MeasureSpec.UNSPECIFIED));
        measuredSize.x += contentView.getMeasuredWidth();
        measuredSize.y += contentView.getMeasuredHeight();

        // Prevent scrolling past limit, if estimated sizes were different
        int maxScrollY = Math.max(0, contentView.getMeasuredHeight() - paddedHeightSize);
        if (getScrollY() > maxScrollY)
        {
            scrollTo(getScrollX(), maxScrollY);
            contentView.measure(MeasureSpec.makeMeasureSpec(paddedWidthSize, childWidthSpec), MeasureSpec.makeMeasureSpec(paddedHeightSize, MeasureSpec.UNSPECIFIED));
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
        setMeasuredDimension(measuredSize.x, measuredSize.y);
    }

    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom)
    {
        if (contentView != null)
        {
            contentView.layout(getPaddingLeft(), getPaddingTop(), getPaddingLeft() + contentView.getMeasuredWidth(), getPaddingTop() + contentView.getMeasuredHeight());
        }
    }


    // ---
    // Drag state enum
    // ---

    private enum DragState
    {
        Idle,
        Scrolling,
        Swiping
    }


    // ---
    // Layout container
    // ---

    private static class LayoutContainer extends ViewGroup implements DataSetChangedListener
    {
        // ---
        // Members
        // ---

        private Map<String, ViewType> viewTypes = new HashMap<>();
        private List<UsingView> usingViews = new ArrayList<>();
        private List<UsingView> reserveViews = new ArrayList<>();
        private Adapter adapter;
        private int offsetY;
        private int countedHeight;
        private int countedViews;
        private int extraMarginY;
        private int usingViewStartPosition;
        private int usingViewStartY;
        private Point measuredSize = new Point();
        private Point[] measuredViews = null;
        private boolean multiSelect;


        // ---
        // Initialization
        // ---

        public LayoutContainer(Context context)
        {
            this(context, (AttributeSet)null);
        }

        public LayoutContainer(Context context, AttributeSet attrs)
        {
            super(context, attrs);
            init(attrs);
        }

        public LayoutContainer(Context context, AttributeSet attrs, int defStyleAttr)
        {
            this(context, attrs);
        }

        public LayoutContainer(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes)
        {
            this(context, attrs);
        }

        private void init(AttributeSet attrs)
        {
            extraMarginY = (int)(getResources().getDisplayMetrics().density * 64);
        }


        // ---
        // Settings
        // ---

        public void setMultiSelect(boolean multiSelect)
        {
            this.multiSelect = multiSelect;
            if (!multiSelect && adapter != null)
            {
                int foundSelections = 0;
                int count = getReusableViewCount();
                for (int i = 0; i < count; i++)
                {
                    if (isItemSelected(i))
                    {
                        foundSelections++;
                        if (foundSelections > 1)
                        {
                            break;
                        }
                    }
                }
                if (foundSelections > 1)
                {
                    adapter.clearSelections();
                }
            }
        }


        // ---
        // Adapter interaction
        // ---

        public void setAdapter(Adapter adapter)
        {
            if (this.adapter != null)
            {
                this.adapter.removeDataSetChangedListener(this);
            }
            this.adapter = adapter;
            this.adapter.addDataSetChangedListener(this);
        }

        @Override
        public void onDataSetChanged()
        {
            refreshCalculation();
            requestLayout();
        }

        @Override
        public void onDataItemChanged(int itemPosition)
        {
            if (itemPosition >= usingViewStartPosition && itemPosition < usingViewStartPosition + usingViews.size())
            {
                usingViews.get(itemPosition - usingViewStartPosition).invalidated = true;
                requestLayout();
            }
        }

        @Override
        public void onDataItemStateChanged(int itemPosition)
        {
            if (itemPosition >= usingViewStartPosition && itemPosition < usingViewStartPosition + usingViews.size())
            {
                UsingView usingView = usingViews.get(itemPosition - usingViewStartPosition);
                if (usingView.view != null)
                {
                    usingView.view.setSelected(isItemSelected(itemPosition), true);
                    usingView.view.setEnabled(isItemEnabled(itemPosition), true);
                }
                if (!multiSelect && isItemSelected(itemPosition) && adapter != null)
                {
                    int count = getReusableViewCount();
                    for (int i = 0; i < count; i++)
                    {
                        if (i != itemPosition && isItemSelected(i))
                        {
                            adapter.setItemSelected(i, false);
                        }
                    }
                }
            }
        }

        public void refreshCalculation()
        {
            for (UsingView usingView : usingViews)
            {
                if (usingView != null && usingView.view != null)
                {
                    removeView(usingView.view);
                }
            }
            measuredViews = new Point[getReusableViewCount()];
            viewTypes.clear();
            usingViews.clear();
            countedHeight = 0;
            countedViews = 0;
            usingViewStartPosition = 0;
            usingViewStartY = 0;
        }

        private int getReusableViewCount()
        {
            return adapter != null ? adapter.getItemCount() : 0;
        }

        private String getReusableViewType(int position)
        {
            return adapter != null ? adapter.getItemViewType(position) : "undefined";
        }

        private boolean isItemSelected(int position)
        {
            return adapter != null && adapter.isItemSelected(position);
        }

        private boolean isItemEnabled(int position)
        {
            return adapter == null || adapter.isItemEnabled(position);
        }

        private void initReusableView(UniReusableView container, String viewType)
        {
            if (adapter != null)
            {
                container.setItemView(adapter.onCreateView(container, viewType));
                container.setUnderView(adapter.onCreateUnderView(container, viewType));
            }
            else
            {
                container.setItemView(null);
                container.setUnderView(null);
            }
        }

        private void updateReusableView(UniReusableView container, String viewType, int position)
        {
            if (adapter != null)
            {
                adapter.onUpdateView(container, container.getItemView(), viewType, position);
                adapter.onUpdateUnderView(container, container.getUnderView(), viewType, position);
                container.setSelected(isItemSelected(position), false);
                container.setEnabled(isItemEnabled(position), false);
                if (position == adapter.itemSwipedOpen)
                {
                    container.swipeOpen(false);
                }
                else
                {
                    container.swipeClose(false);
                }
            }
        }


        // ---
        // Track size measurement
        // ---

        public void setLastMeasuredSize(int position, int width, int height)
        {
            // Store in last measured array
            if (position < measuredViews.length)
            {
                if (measuredViews[position] != null)
                {
                    measuredViews[position].x = width;
                    measuredViews[position].y = height;
                }
                else
                {
                    measuredViews[position] = new Point(width, height);
                }
            }

            // Apply to size averaging (including normalization if sizes get too big)
            String viewType = getReusableViewType(position);
            if (viewType != null)
            {
                ViewType adjustViewType = viewTypes.get(viewType);
                if (adjustViewType == null)
                {
                    adjustViewType = new ViewType();
                    viewTypes.put(viewType, adjustViewType);
                }
                adjustViewType.countedViews++;
                adjustViewType.countedHeight += height;
                if (adjustViewType.countedHeight > 0x10000000)
                {
                    int reduceViews = (adjustViewType.countedViews + 1) / 2;
                    adjustViewType.countedHeight -= reduceViews * (adjustViewType.countedHeight / adjustViewType.countedViews);
                    adjustViewType.countedViews -= reduceViews;
                }
            }
            countedViews++;
            countedHeight += height;
            if (countedHeight > 0x10000000)
            {
                int reduceViews = (countedViews + 1) / 2;
                countedHeight -= reduceViews * (countedHeight / countedViews);
                countedViews -= reduceViews;
            }
        }

        public int getEstimatedHeight(int position)
        {
            if (position < measuredViews.length && measuredViews[position] != null)
            {
                return measuredViews[position].y;
            }
            return getAverageHeight(adapter.getItemViewType(position));
        }

        public int getAverageHeight(String viewType)
        {
            if (viewType != null)
            {
                ViewType viewTypeInfo = viewTypes.get(viewType);
                if (viewTypeInfo != null && viewTypeInfo.countedViews > 0)
                {
                    return viewTypeInfo.countedHeight / viewTypeInfo.countedViews;
                }
            }
            if (countedViews > 0)
            {
                return countedHeight / countedViews;
            }
            return (int)getResources().getDisplayMetrics().density * 50;
        }

        public int getLastMeasuredWidth(int position)
        {
            if (position < measuredViews.length && measuredViews[position] != null)
            {
                return measuredViews[position].x;
            }
            return 0;
        }

        public int getReusableViewY(int position)
        {
            // First calculate sizes of at least a screen before the requested item
            int paddedWidthSize = getWidth() - getPaddingLeft() - getPaddingRight();
            int needsCalculation = ((UniReusingContainer)getParent()).getHeight() + extraMarginY;
            for (int i = position; i >= 0; i--)
            {
                if (i < usingViewStartPosition || i >= usingViewStartPosition + usingViews.size())
                {
                    UniReusableView reusableView = allocateReserveView(i);
                    if (reusableView != null)
                    {
                        reusableView.measure(MeasureSpec.makeMeasureSpec(paddedWidthSize, MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(0xFFFFFF, MeasureSpec.UNSPECIFIED));
                        setLastMeasuredSize(i, reusableView.getMeasuredWidth(), reusableView.getMeasuredHeight());
                    }
                }
                needsCalculation -= getEstimatedHeight(i);
                if (needsCalculation < 0)
                {
                    break;
                }
            }

            // Determine the position and return the result
            int y = 0;
            for (int i = 0; i < position; i++)
            {
                y += getEstimatedHeight(i);
            }
            return y;
        }


        // ---
        // Reusable view creation
        // ---

        public void setOffsetY(int offsetY)
        {
            // Request a new layout pass if items are about to enter view (ignore views going to exit for performance)
            int startY = Math.max(getPaddingTop(), getPaddingTop() + offsetY - extraMarginY);
            int endY = getPaddingTop() + offsetY + ((View)getParent()).getHeight() + extraMarginY;
            int endItemY = usingViewStartY;
            for (int i = usingViewStartPosition; i < usingViewStartPosition + usingViews.size(); i++)
            {
                endItemY += getEstimatedHeight(i);
            }
            if (startY < usingViewStartY || endY > endItemY)
            {
                requestLayout();
            }

            // Apply new offset
            this.offsetY = offsetY;
        }

        public UniReusableView getReusableView(int position, boolean includeAll)
        {
            if (position >= usingViewStartPosition && position < usingViewStartPosition + usingViews.size())
            {
                return usingViews.get(position - usingViewStartPosition).view;
            }
            if (includeAll)
            {
                UniReusableView view = allocateReserveView(position);
                return view;
            }
            return null;
        }

        private UniReusableView allocateReusableView(int position)
        {
            // Expand array if there is no item for the position
            if (position < usingViewStartPosition)
            {
                for (int i = position; i < usingViewStartPosition; i++)
                {
                    usingViews.add(0, null);
                }
                usingViewStartPosition = position;
            }
            else if (position >= usingViewStartPosition + usingViews.size())
            {
                for (int i = usingViewStartPosition + usingViews.size(); i <= position; i++)
                {
                    usingViews.add(null);
                }
            }

            // Clear the view taking up the given position, or use the item already prepared for this position
            String viewType = getReusableViewType(position);
            UniReusableView reusableView = null;
            UsingView usingView = usingViews.get(position - usingViewStartPosition);
            if (usingView != null)
            {
                if (usingView.viewType.equals(viewType))
                {
                    reusableView = usingView.view;
                }
                else
                {
                    reserveViews.add(usingView);
                    removeView(usingView.view);
                    usingViews.set(position - usingViewStartPosition, null);
                }
            }

            // If not found, create a new view
            if (reusableView == null)
            {
                usingView = null;
                for (UsingView checkUsingView : reserveViews)
                {
                    if (checkUsingView.viewType.equals(viewType))
                    {
                        usingView = checkUsingView;
                        reserveViews.remove(checkUsingView);
                        break;
                    }
                }
                if (usingView == null)
                {
                    usingView = new UsingView();
                    reusableView = new UniReusableView(getContext());
                    reusableView.setLayoutParams(new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
                    initReusableView(reusableView, viewType);
                    reusableView.setOnClickListener(new OnClickListener()
                    {
                        @Override
                        public void onClick(View view)
                        {
                            onReusableViewClick(view);
                        }
                    });
                    addView(reusableView);
                }
                else
                {
                    reusableView = usingView.view;
                    addView(reusableView);
                }
                usingView.view = reusableView;
                usingView.viewType = viewType;
                usingViews.set(position - usingViewStartPosition, usingView);
            }

            // Populate and return result
            updateReusableView(reusableView, viewType, position);
            return reusableView;
        }

        private UniReusableView allocateReserveView(int position)
        {
            UniReusableView reusableView;
            UsingView usingView = null;
            String viewType = getReusableViewType(position);
            for (UsingView checkUsingView : reserveViews)
            {
                if (checkUsingView.viewType.equals(viewType))
                {
                    usingView = checkUsingView;
                    break;
                }
            }
            if (usingView == null)
            {
                usingView = new UsingView();
                reusableView = new UniReusableView(getContext());
                reusableView.setLayoutParams(new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
                initReusableView(reusableView, viewType);
                usingView.view = reusableView;
                usingView.viewType = viewType;
                reusableView.setOnClickListener(new OnClickListener()
                {
                    @Override
                    public void onClick(View view)
                    {
                        onReusableViewClick(view);
                    }
                });
                reserveViews.add(usingView);
            }
            else
            {
                reusableView = usingView.view;
            }
            updateReusableView(reusableView, viewType, position);
            return reusableView;
        }

        private void onReusableViewClick(View view)
        {
            if (getParent() instanceof UniReusingContainer && view instanceof UniReusableView && adapter != null)
            {
                int position = ((UniReusingContainer)getParent()).getAdapterPosition((UniReusableView)view);
                if (isItemEnabled(position))
                {
                    adapter.setItemSelected(position, !isItemSelected(position));
                }
            }
        }


        // ---
        // Custom layout
        // ---

        @Override
        protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec)
        {
            // Determine available size without padding
            int widthSpec = MeasureSpec.getMode(widthMeasureSpec);
            int heightSpec = MeasureSpec.getMode(heightMeasureSpec);
            int widthSize = MeasureSpec.getSize(widthMeasureSpec);
            int heightSize = MeasureSpec.getSize(heightMeasureSpec);
            int paddedWidthSize = widthSize - getPaddingLeft() - getPaddingRight();
            int paddedHeightSize = heightSize - getPaddingTop() - getPaddingBottom();
            measuredSize.x = getPaddingLeft();
            measuredSize.y = getPaddingTop();
            if (widthSpec == MeasureSpec.UNSPECIFIED) // Only do this for width, the height size will be needed for optimization reasons
            {
                paddedWidthSize = 0xFFFFFF;
            }

            // Obtain invalidated or empty items
            int childWidthSpec = MeasureSpec.AT_MOST;
            if (widthSpec == MeasureSpec.EXACTLY)
            {
                childWidthSpec = MeasureSpec.EXACTLY;
            }
            for (int i = 0; i < usingViews.size(); i++)
            {
                if (usingViews.get(i) == null || usingViews.get(i).invalidated)
                {
                    UniReusableView reusableView = allocateReusableView(usingViewStartPosition + i);
                    if (reusableView != null)
                    {
                        reusableView.measure(MeasureSpec.makeMeasureSpec(paddedWidthSize, childWidthSpec), MeasureSpec.makeMeasureSpec(0xFFFFFF, MeasureSpec.UNSPECIFIED));
                        setLastMeasuredSize(usingViewStartPosition + i, reusableView.getMeasuredWidth(), reusableView.getMeasuredHeight());
                        usingViews.get(i).invalidated = false;
                    }
                }
            }

            // Re-measure items in view
            for (int i = 0; i < usingViews.size(); i++)
            {
                if (usingViews.get(i) != null)
                {
                    UniReusableView reusableView = usingViews.get(i).view;
                    if (reusableView.isLayoutRequested())
                    {
                        reusableView.measure(MeasureSpec.makeMeasureSpec(paddedWidthSize, childWidthSpec), MeasureSpec.makeMeasureSpec(0xFFFFFF, MeasureSpec.UNSPECIFIED));
                        setLastMeasuredSize(usingViewStartPosition + i, reusableView.getMeasuredWidth(), reusableView.getMeasuredHeight());
                        usingViews.get(i).invalidated = false;
                    }
                }
            }

            // Determine range and remove items falling out of view
            int startY = Math.max(getPaddingTop(), getPaddingTop() + offsetY - extraMarginY);
            int endY = getPaddingTop() + offsetY + paddedHeightSize + extraMarginY;
            int endItemY = usingViewStartY;
            for (int i = usingViewStartPosition; i < usingViewStartPosition + usingViews.size(); i++)
            {
                endItemY += getEstimatedHeight(i);
            }
            while (usingViews.size() > 0 && usingViewStartY + getEstimatedHeight(usingViewStartPosition) < startY)
            {
                UsingView usingView = usingViews.get(0);
                if (usingView != null)
                {
                    reserveViews.add(usingView);
                    removeView(usingView.view);
                }
                usingViews.remove(0);
                usingViewStartY += getEstimatedHeight(usingViewStartPosition);
                usingViewStartPosition++;
            }
            while (usingViews.size() > 0 && endItemY - getEstimatedHeight(usingViewStartPosition + usingViews.size() - 1) >= endY)
            {
                UsingView usingView = usingViews.get(usingViews.size() - 1);
                endItemY -= getEstimatedHeight(usingViewStartPosition + usingViews.size() - 1);
                if (usingView != null)
                {
                    reserveViews.add(usingView);
                    removeView(usingView.view);
                }
                usingViews.remove(usingViews.size() - 1);
            }

            // Add items moving into view
            int scrollCorrection = 0;
            for (int i = usingViewStartPosition + usingViews.size(); i < getReusableViewCount(); i++)
            {
                if (endItemY >= endY)
                {
                    break;
                }
                UniReusableView reusableView = allocateReusableView(i);
                if (reusableView != null)
                {
                    reusableView.measure(MeasureSpec.makeMeasureSpec(paddedWidthSize, childWidthSpec), MeasureSpec.makeMeasureSpec(0xFFFFFF, MeasureSpec.UNSPECIFIED));
                    endItemY += reusableView.getMeasuredHeight();
                    setLastMeasuredSize(i, reusableView.getMeasuredWidth(), reusableView.getMeasuredHeight());
                }
            }
            for (int i = usingViewStartPosition - 1; i >= 0; i--)
            {
                if (usingViewStartY + getEstimatedHeight(usingViewStartPosition) + scrollCorrection <= startY)
                {
                    break;
                }
                UniReusableView reusableView = allocateReusableView(i);
                if (reusableView != null)
                {
                    int previousHeight = getEstimatedHeight(i);
                    reusableView.measure(MeasureSpec.makeMeasureSpec(paddedWidthSize, childWidthSpec), MeasureSpec.makeMeasureSpec(0xFFFFFF, MeasureSpec.UNSPECIFIED));
                    scrollCorrection += reusableView.getMeasuredHeight() - previousHeight;
                    usingViewStartY -= reusableView.getMeasuredHeight();
                    setLastMeasuredSize(i, reusableView.getMeasuredWidth(), reusableView.getMeasuredHeight());
                }
            }

            // Apply scroll correction (if needed)
            if (scrollCorrection != 0)
            {
                ScrollView parent = (ScrollView)getParent();
                usingViewStartY += scrollCorrection;
                parent.scrollTo(parent.getScrollX(), parent.getScrollY() + scrollCorrection);
            }

            // Use sizes calculated earlier for container measurement
            int viewCount = getReusableViewCount();
            int maxWidth = 0;
            for (int i = 0; i < viewCount; i++)
            {
                maxWidth = Math.max(maxWidth, getLastMeasuredWidth(i));
                measuredSize.y += getEstimatedHeight(i);
            }
            measuredSize.x += maxWidth;

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
            setMeasuredDimension(measuredSize.x, measuredSize.y);
        }

        @Override
        protected void onLayout(boolean changed, int left, int top, int right, int bottom)
        {
            int y = usingViewStartY;
            for (int i = 0; i < usingViews.size(); i++)
            {
                UsingView usingView = usingViews.get(i);
                if (usingView != null)
                {
                    usingView.view.layout(0, y, usingView.view.getMeasuredWidth(), y + usingView.view.getMeasuredHeight());
                }
                y += getEstimatedHeight(usingViewStartPosition + i);
            }
        }
    }


    // ---
    // A view type utility
    // ---

    private static class UsingView
    {
        private String viewType;
        private UniReusableView view;
        private boolean invalidated;
    }


    // ---
    // A view type utility
    // ---

    private static class ViewType
    {
        private int countedHeight;
        private int countedViews;
    }


    // ---
    // Adapter to create reusable views
    // ---

    public static abstract class Adapter
    {
        private List<DataSetChangedListener> dataSetChangedListeners = new ArrayList<>();
        private boolean[] itemsSelected;
        private boolean[] itemsEnabled;
        private int itemSwipedOpen = -1;

        public abstract View onCreateView(UniReusableView container, String viewType);
        public abstract void onUpdateView(UniReusableView container, View view, String viewType, int itemPosition);
        public abstract int getItemCount();

        public View onCreateUnderView(UniReusableView container, String viewType)
        {
            return null;
        }

        public void onUpdateUnderView(UniReusableView container, View view, String viewType, int itemPosition)
        {
        }

        public String getItemViewType(int itemPosition)
        {
            return "default";
        }

        public void onSelectionChanged(int itemPosition, boolean selected)
        {
        }

        public void setItemSelected(int itemPosition, boolean selected)
        {
            if (itemsSelected != null && itemPosition >= 0 && itemPosition < itemsSelected.length)
            {
                boolean changed = itemsSelected[itemPosition] != selected;
                itemsSelected[itemPosition] = selected;
                if (changed)
                {
                    onSelectionChanged(itemPosition, selected);
                    notifyItemStateChanged(itemPosition);
                }
            }
        }

        public void setItemEnabled(int itemPosition, boolean enabled)
        {
            if (itemsEnabled != null && itemPosition >= 0 && itemPosition < itemsEnabled.length)
            {
                boolean changed = itemsEnabled[itemPosition] != enabled;
                itemsEnabled[itemPosition] = enabled;
                if (changed)
                {
                    notifyItemStateChanged(itemPosition);
                }
            }
        }

        public boolean isItemSelected(int itemPosition)
        {
            if (itemsSelected != null && itemPosition >= 0 && itemPosition < itemsSelected.length)
            {
                return itemsSelected[itemPosition];
            }
            return false;
        }

        public boolean isItemEnabled(int itemPosition)
        {
            if (itemsEnabled != null && itemPosition >= 0 && itemPosition < itemsEnabled.length)
            {
                return itemsEnabled[itemPosition];
            }
            return true;
        }

        public void clearSelections()
        {
            if (itemsSelected != null)
            {
                for (int i = 0; i < itemsSelected.length; i++)
                {
                    if (itemsSelected[i])
                    {
                        itemsSelected[i] = false;
                        notifyItemChanged(i);
                    }
                }
            }
        }

        public void notifyDataSetChanged()
        {
            for (DataSetChangedListener listener : dataSetChangedListeners)
            {
                listener.onDataSetChanged();
            }
            itemsSelected = new boolean[getItemCount()];
            itemsEnabled = new boolean[getItemCount()];
            for (int i = 0; i < itemsEnabled.length; i++)
            {
                itemsEnabled[i] = true;
            }
        }

        public void notifyItemChanged(int itemPosition)
        {
            for (DataSetChangedListener listener : dataSetChangedListeners)
            {
                listener.onDataItemChanged(itemPosition);
            }
        }

        public void notifyItemStateChanged(int itemPosition)
        {
            for (DataSetChangedListener listener : dataSetChangedListeners)
            {
                listener.onDataItemStateChanged(itemPosition);
            }
        }

        public void removeDataSetChangedListener(DataSetChangedListener listener)
        {
            dataSetChangedListeners.remove(listener);
        }

        public void addDataSetChangedListener(DataSetChangedListener listener)
        {
            if (!dataSetChangedListeners.contains(listener))
            {
                dataSetChangedListeners.add(listener);
            }
        }
    }


    // ---
    // Listener for adapter changes
    // ---

    public interface DataSetChangedListener
    {
        void onDataSetChanged();
        void onDataItemChanged(int itemPosition);
        void onDataItemStateChanged(int itemPosition);
    }
}
